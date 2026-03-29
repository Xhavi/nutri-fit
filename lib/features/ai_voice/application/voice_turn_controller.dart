import 'package:flutter/foundation.dart';

import '../domain/contracts/audio_player.dart';
import '../domain/contracts/audio_recorder.dart';
import '../domain/models/voice_playback_state.dart';
import '../domain/models/voice_recording_state.dart';
import '../domain/models/voice_turn_models.dart';
import '../domain/repositories/ai_voice_repository.dart';
import 'voice_turn_state.dart';

class VoiceTurnController extends ChangeNotifier {
  VoiceTurnController({
    required AiVoiceRepository repository,
    required AudioRecorder recorder,
    required AudioPlayer player,
  }) : _repository = repository,
       _recorder = recorder,
       _player = player,
       _state = VoiceTurnState.initial();

  final AiVoiceRepository _repository;
  final AudioRecorder _recorder;
  final AudioPlayer _player;

  VoiceTurnState _state;
  VoiceTurnState get state => _state;

  Future<void> startRecording() async {
    if (!_state.recording.canStart || _state.isBusy) {
      return;
    }

    _state = _state.copyWith(
      status: VoiceTurnStatus.recording,
      clearErrorMessage: true,
      recording: _state.recording.copyWith(status: VoiceRecordingStatus.requestingPermission),
    );
    notifyListeners();

    try {
      await _recorder.requestPermission();
      await _recorder.startRecording();

      _state = _state.copyWith(
        status: VoiceTurnStatus.recording,
        recording: _state.recording.copyWith(
          status: VoiceRecordingStatus.recording,
          elapsed: Duration.zero,
          clearLocalFilePath: true,
          clearLevel: true,
          clearErrorMessage: true,
        ),
      );
      notifyListeners();
    } catch (_) {
      _state = _state.copyWith(
        status: VoiceTurnStatus.error,
        errorMessage: 'No fue posible iniciar la grabación de voz.',
        recording: _state.recording.copyWith(
          status: VoiceRecordingStatus.error,
          errorMessage: 'Permiso denegado o micrófono no disponible.',
        ),
      );
      notifyListeners();
    }
  }

  Future<void> stopRecordingAndSend({
    String? transcript,
    VoiceUserContext? userContext,
    String? voiceStyleInstructions,
  }) async {
    if (!_state.recording.canStop || _state.isBusy) {
      return;
    }

    _state = _state.copyWith(
      status: VoiceTurnStatus.uploading,
      recording: _state.recording.copyWith(status: VoiceRecordingStatus.stopping),
      clearErrorMessage: true,
    );
    notifyListeners();

    try {
      final String path = await _recorder.stopRecording();
      final List<int> audioBytes = await _recorder.readRecordingBytes(path);

      final VoiceTurnRequest request = VoiceTurnRequest(
        inputAudio: audioBytes,
        transcript: transcript,
        userContext: userContext,
        voiceStyleInstructions: voiceStyleInstructions,
      );

      _state = _state.copyWith(
        status: VoiceTurnStatus.processing,
        recording: _state.recording.copyWith(
          status: VoiceRecordingStatus.completed,
          localFilePath: path,
        ),
      );
      notifyListeners();

      final VoiceTurnResponse response = await _repository.sendVoiceTurn(request);

      _state = _state.copyWith(
        status: VoiceTurnStatus.playing,
        lastResponse: response,
        playback: _state.playback.copyWith(
          status: VoicePlaybackStatus.preparing,
          clearErrorMessage: true,
        ),
      );
      notifyListeners();

      // TODO(V1): Integrar reproducción real del audio de respuesta.
      await _player.playBytes(response.outputAudio, mimeType: response.outputAudioMimeType);

      _state = _state.copyWith(
        status: VoiceTurnStatus.done,
        playback: _state.playback.copyWith(status: VoicePlaybackStatus.completed),
      );
      notifyListeners();
    } catch (_) {
      _state = _state.copyWith(
        status: VoiceTurnStatus.error,
        errorMessage: 'No fue posible completar el turno de voz.',
        playback: _state.playback.copyWith(
          status: VoicePlaybackStatus.error,
          errorMessage: 'Fallo en backend o reproducción.',
        ),
      );
      notifyListeners();
    }
  }

  Future<void> stopPlayback() async {
    await _player.stop();

    _state = _state.copyWith(
      status: VoiceTurnStatus.idle,
      playback: _state.playback.copyWith(
        status: VoicePlaybackStatus.idle,
        position: Duration.zero,
      ),
    );
    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(clearErrorMessage: true);
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
}
