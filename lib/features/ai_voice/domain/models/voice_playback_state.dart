enum VoicePlaybackStatus {
  idle,
  preparing,
  playing,
  paused,
  completed,
  error,
}

class VoicePlaybackState {
  const VoicePlaybackState({
    required this.status,
    this.position = Duration.zero,
    this.duration,
    this.errorMessage,
  });

  final VoicePlaybackStatus status;
  final Duration position;
  final Duration? duration;
  final String? errorMessage;

  bool get isPlaying => status == VoicePlaybackStatus.playing;

  VoicePlaybackState copyWith({
    VoicePlaybackStatus? status,
    Duration? position,
    Duration? duration,
    String? errorMessage,
    bool clearDuration = false,
    bool clearErrorMessage = false,
  }) {
    return VoicePlaybackState(
      status: status ?? this.status,
      position: position ?? this.position,
      duration: clearDuration ? null : (duration ?? this.duration),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  factory VoicePlaybackState.initial() {
    return const VoicePlaybackState(status: VoicePlaybackStatus.idle);
  }
}
