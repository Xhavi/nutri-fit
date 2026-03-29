import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/local_storage_service.dart';
import '../domain/contracts/audio_player.dart';
import '../domain/contracts/audio_recorder.dart';
import '../domain/models/voice_playback_state.dart';
import '../domain/models/voice_profile.dart';
import '../domain/models/voice_recording_state.dart';
import '../domain/models/voice_turn_models.dart';
import '../domain/repositories/ai_voice_repository.dart';
import 'voice_turn_state.dart';

class VoiceTurnController extends ChangeNotifier {
  VoiceTurnController({
    required AiVoiceRepository repository,
    required AudioRecorder recorder,
    required AudioPlayer player,
    required LocalStorageService localStorage,
  }) : _repository = repository,
       _recorder = recorder,
       _player = player,
       _localStorage = localStorage,
       _state = VoiceTurnState.initial() {
    _restorePreferences();
  }

  static const String _voiceProfileKey = 'ai_voice.selected_profile.v2';
  static const String _autoplayKey = 'ai_voice.autoplay_enabled.v2';

  final AiVoiceRepository _repository;
  final AudioRecorder _recorder;
  final AudioPlayer _player;
  final LocalStorageService _localStorage;

  VoiceTurnState _state;
  VoiceTurnState get state => _state;

  Future<void> _restorePreferences() async {
    final String? savedProfileId = await _localStorage.getString(_voiceProfileKey);
    final bool autoplayEnabled = await _localStorage.getBool(_autoplayKey) ?? true;

    final VoiceProfile selectedProfile = _state.availableProfiles.firstWhere(
      (VoiceProfile profile) => profile.id == savedProfileId,
      orElse: VoiceProfile.fallback,
    );

    _state = _state.copyWith(
      selectedVoiceProfile: selectedProfile,
      autoplayEnabled: autoplayEnabled,
    );
    notifyListeners();
  }

  Future<void> setVoiceProfile(VoiceProfile profile) async {
    _state = _state.copyWith(selectedVoiceProfile: profile);
    notifyListeners();
    await _localStorage.setString(_voiceProfileKey, profile.id);
  }

  Future<void> setAutoplayEnabled(bool value) async {
    _state = _state.copyWith(autoplayEnabled: value);
    notifyListeners();
    await _localStorage.setBool(_autoplayKey, value);
  }

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
        voiceProfile: _state.selectedVoiceProfile,
        voiceStyleInstructions:
            voiceStyleInstructions ?? _state.selectedVoiceProfile.styleInstructions,
        voiceRate: _suggestedRateForProfile(_state.selectedVoiceProfile),
        voiceIntent: _intentForProfile(_state.selectedVoiceProfile),
      );

      final VoiceTurnResponse response = await _repository.sendVoiceTurn(request);

      _state = _state.copyWith(
        status: VoiceTurnStatus.responseReady,
        lastResponse: response,
        history: <VoiceTurnHistoryItem>[
          VoiceTurnHistoryItem(
            createdAt: DateTime.now(),
            inputAudioPath: path,
            userTranscript: response.userTranscript,
            assistantText: response.assistantText,
            voiceProfileUsed: response.voiceProfileUsed,
            outputAudioBytes: response.outputAudioBytes,
            outputAudioMimeType: response.outputAudioMimeType,
          ),
          ..._state.history,
        ],
        playback: _state.playback.copyWith(
          status: VoicePlaybackStatus.preparing,
          clearErrorMessage: true,
        ),
      );
      notifyListeners();

      if (_state.autoplayEnabled && response.outputAudioBytes.isNotEmpty) {
        await replayLastResponse();
      } else {
        _state = _state.copyWith(
          status: VoiceTurnStatus.responseReady,
          playback: _state.playback.copyWith(status: VoicePlaybackStatus.completed),
        );
        notifyListeners();
      }
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

  Future<void> replayLastResponse() async {
    final VoiceTurnResponse? response = _state.lastResponse;
    if (response == null || response.outputAudioBytes.isEmpty) {
      _state = _state.copyWith(
        status: VoiceTurnStatus.error,
        errorMessage: 'No hay audio de respuesta para reproducir.',
      );
      notifyListeners();
      return;
    }

    try {
      _state = _state.copyWith(
        status: VoiceTurnStatus.playingAudio,
        playback: _state.playback.copyWith(status: VoicePlaybackStatus.playing),
        clearErrorMessage: true,
      );
      notifyListeners();

      await _player.playBytes(
        response.outputAudioBytes,
        mimeType: response.outputAudioMimeType,
      );

      _state = _state.copyWith(
        status: VoiceTurnStatus.responseReady,
        playback: _state.playback.copyWith(status: VoicePlaybackStatus.completed),
      );
      notifyListeners();
    } catch (_) {
      _state = _state.copyWith(
        status: VoiceTurnStatus.error,
        errorMessage: 'No fue posible reproducir nuevamente la respuesta.',
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
        VoiceTurnRequest(
          inputAudio: audioBytes,
          voiceProfile: _state.selectedVoiceProfile,
          voiceStyleInstructions: _state.selectedVoiceProfile.styleInstructions,
          voiceRate: _suggestedRateForProfile(_state.selectedVoiceProfile),
          voiceIntent: _intentForProfile(_state.selectedVoiceProfile),
        ),
      );

      _state = _state.copyWith(
        status: VoiceTurnStatus.responseReady,
        lastResponse: response,
        playback: _state.playback.copyWith(status: VoicePlaybackStatus.preparing),
      );
      notifyListeners();

      if (_state.autoplayEnabled && response.outputAudioBytes.isNotEmpty) {
        await replayLastResponse();
      } else {
        _state = _state.copyWith(
          status: VoiceTurnStatus.responseReady,
          playback: _state.playback.copyWith(status: VoicePlaybackStatus.completed),
        );
        notifyListeners();
      }
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

  double _suggestedRateForProfile(VoiceProfile profile) {
    switch (profile.id) {
      case 'energetic':
        return 1.08;
      case 'calm':
        return 0.92;
      case 'professional':
        return 1.0;
      case 'warm':
      default:
        return 0.98;
    }
  }

  String _intentForProfile(VoiceProfile profile) {
    switch (profile.id) {
      case 'energetic':
        return 'motivational';
      case 'calm':
        return 'reassuring';
      case 'professional':
        return 'structured';
      case 'warm':
      default:
        return 'friendly';
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
}
