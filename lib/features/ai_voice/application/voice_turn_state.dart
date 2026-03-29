import '../domain/models/voice_playback_state.dart';
import '../domain/models/voice_recording_state.dart';
import '../domain/models/voice_turn_models.dart';

enum VoiceTurnStatus {
  idle,
  requestingPermission,
  recording,
  uploading,
  processingBackend,
  responseReady,
  playingAudio,
  error,
}

class VoiceTurnState {
  const VoiceTurnState({
    required this.status,
    required this.recording,
    required this.playback,
    this.lastResponse,
    this.errorMessage,
  });

  final VoiceTurnStatus status;
  final VoiceRecordingState recording;
  final VoicePlaybackState playback;
  final VoiceTurnResponse? lastResponse;
  final String? errorMessage;

  bool get isBusy =>
      status == VoiceTurnStatus.requestingPermission ||
      status == VoiceTurnStatus.uploading ||
      status == VoiceTurnStatus.processingBackend ||
      recording.isBusy;

  VoiceTurnState copyWith({
    VoiceTurnStatus? status,
    VoiceRecordingState? recording,
    VoicePlaybackState? playback,
    VoiceTurnResponse? lastResponse,
    String? errorMessage,
    bool clearLastResponse = false,
    bool clearErrorMessage = false,
  }) {
    return VoiceTurnState(
      status: status ?? this.status,
      recording: recording ?? this.recording,
      playback: playback ?? this.playback,
      lastResponse: clearLastResponse ? null : (lastResponse ?? this.lastResponse),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  factory VoiceTurnState.initial() {
    return VoiceTurnState(
      status: VoiceTurnStatus.idle,
      recording: VoiceRecordingState.initial(),
      playback: VoicePlaybackState.initial(),
    );
  }
}
