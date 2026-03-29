import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
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
      status: VoiceTurnStatus.requestingPermission,
      clearErrorMessage: true,
      clearLastResponse: true,
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

  Future<void> stopRecording({
    bool sendAfterStop = true,
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
      if (audioBytes.isEmpty) {
        throw AppException('Audio vacío o corrupto.');
      }

      _state = _state.copyWith(
        status: VoiceTurnStatus.processingBackend,
        recording: _state.recording.copyWith(
          status: VoiceRecordingStatus.completed,
          localFilePath: path,
          clearErrorMessage: true,
        ),
      );
      notifyListeners();

      if (!sendAfterStop) {
        return;
      }

      final VoiceTurnRequest request = VoiceTurnRequest(
        inputAudio: audioBytes,
        transcript: transcript,
        userContext: userContext,
        voiceStyleInstructions: voiceStyleInstructions,
      );

      final VoiceTurnResponse response = await _repository.sendVoiceTurn(request);

      _state = _state.copyWith(
        status: VoiceTurnStatus.responseReady,
        lastResponse: response,
        playback: _state.playback.copyWith(
          status: VoicePlaybackStatus.preparing,
          clearErrorMessage: true,
        ),
      );
      notifyListeners();

      if (response.outputAudioBytes.isNotEmpty) {
        _state = _state.copyWith(
          status: VoiceTurnStatus.playingAudio,
          playback: _state.playback.copyWith(status: VoicePlaybackStatus.playing),
        );
        notifyListeners();

        await _player.playBytes(
          response.outputAudioBytes,
          mimeType: response.outputAudioMimeType,
        );
      }

      _state = _state.copyWith(
        status: VoiceTurnStatus.responseReady,
        playback: _state.playback.copyWith(status: VoicePlaybackStatus.completed),
      );
      notifyListeners();
    } on AppException catch (error) {
      _state = _state.copyWith(
        status: VoiceTurnStatus.error,
        errorMessage: error.message,
        playback: _state.playback.copyWith(
          status: VoicePlaybackStatus.error,
          errorMessage: error.message,
        ),
      );
      notifyListeners();
    } catch (error) {
      _state = _state.copyWith(
        status: VoiceTurnStatus.error,
        errorMessage: 'No fue posible completar el turno de voz: $error',
        playback: _state.playback.copyWith(
          status: VoicePlaybackStatus.error,
          errorMessage: 'Fallo en backend o reproducción.',
        ),
      );
      notifyListeners();
    }
  }

  Future<void> cancelRecording() async {
    if (!_state.recording.canStop) {
      return;
    }

    await _recorder.cancelRecording();
    _state = _state.copyWith(
      status: VoiceTurnStatus.idle,
      recording: _state.recording.copyWith(
        status: VoiceRecordingStatus.idle,
        elapsed: Duration.zero,
        clearLocalFilePath: true,
      ),
      clearErrorMessage: true,
      clearLastResponse: true,
    );
    notifyListeners();
  }

  Future<void> retryLastTurn() async {
    final String? path = _state.recording.localFilePath;
    if (path == null || path.isEmpty) {
      _state = _state.copyWith(
        status: VoiceTurnStatus.error,
        errorMessage: 'No hay audio grabado para reintentar.',
      );
      notifyListeners();
      return;
    }

    try {
      final List<int> audioBytes = await _recorder.readRecordingBytes(path);
      _state = _state.copyWith(
        status: VoiceTurnStatus.processingBackend,
        clearErrorMessage: true,
      );
      notifyListeners();

      final VoiceTurnResponse response = await _repository.sendVoiceTurn(
        VoiceTurnRequest(inputAudio: audioBytes),
      );

      _state = _state.copyWith(
        status: VoiceTurnStatus.responseReady,
        lastResponse: response,
        playback: _state.playback.copyWith(status: VoicePlaybackStatus.preparing),
      );
      notifyListeners();

      if (response.outputAudioBytes.isNotEmpty) {
        _state = _state.copyWith(
          status: VoiceTurnStatus.playingAudio,
          playback: _state.playback.copyWith(status: VoicePlaybackStatus.playing),
        );
        notifyListeners();
        await _player.playBytes(
          response.outputAudioBytes,
          mimeType: response.outputAudioMimeType,
        );
      }

      _state = _state.copyWith(
        status: VoiceTurnStatus.responseReady,
        playback: _state.playback.copyWith(status: VoicePlaybackStatus.completed),
      );
      notifyListeners();
    } catch (_) {
      _state = _state.copyWith(
        status: VoiceTurnStatus.error,
        errorMessage: 'No fue posible reintentar el turno de voz.',
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
