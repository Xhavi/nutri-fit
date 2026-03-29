enum VoiceRecordingStatus {
  idle,
  requestingPermission,
  ready,
  recording,
  stopping,
  completed,
  error,
}

class VoiceRecordingState {
  const VoiceRecordingState({
    required this.status,
    this.elapsed = Duration.zero,
    this.localFilePath,
    this.level,
    this.errorMessage,
  });

  final VoiceRecordingStatus status;
  final Duration elapsed;
  final String? localFilePath;
  final double? level;
  final String? errorMessage;

  bool get isBusy =>
      status == VoiceRecordingStatus.requestingPermission ||
      status == VoiceRecordingStatus.stopping;

  bool get canStart => status == VoiceRecordingStatus.idle || status == VoiceRecordingStatus.ready;

  bool get canStop => status == VoiceRecordingStatus.recording;

  VoiceRecordingState copyWith({
    VoiceRecordingStatus? status,
    Duration? elapsed,
    String? localFilePath,
    double? level,
    String? errorMessage,
    bool clearLocalFilePath = false,
    bool clearLevel = false,
    bool clearErrorMessage = false,
  }) {
    return VoiceRecordingState(
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      localFilePath: clearLocalFilePath ? null : (localFilePath ?? this.localFilePath),
      level: clearLevel ? null : (level ?? this.level),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  factory VoiceRecordingState.initial() {
    return const VoiceRecordingState(status: VoiceRecordingStatus.idle);
  }
}
