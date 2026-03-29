import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase/firebase_service_providers.dart';
import '../../../../core/services/functions/functions_service.dart';
import '../../../auth/presentation/controllers/session_providers.dart';
import '../../application/voice_turn_controller.dart';
import '../../application/voice_turn_state.dart';
import '../../data/clients/ai_voice_api_client.dart';
import '../../data/clients/firebase_ai_voice_api_client.dart';
import '../../data/clients/mock_ai_voice_api_client.dart';
import '../../data/repositories/ai_voice_repository_impl.dart';
import '../../data/services/flutter_audio_player.dart';
import '../../data/services/flutter_audio_recorder.dart';
import '../../domain/contracts/audio_player.dart';
import '../../domain/contracts/audio_recorder.dart';
import '../../domain/repositories/ai_voice_repository.dart';

final Provider<bool> aiVoiceForceMockProvider = Provider<bool>((Ref ref) {
  return const bool.fromEnvironment('AI_VOICE_USE_MOCK', defaultValue: false);
});

final Provider<bool> useAiVoiceMockProvider = Provider<bool>((Ref ref) {
  return ref.watch(aiVoiceForceMockProvider) || ref.watch(useFirebaseMocksProvider);
});

final Provider<AiVoiceApiClient> aiVoiceApiClientProvider = Provider<AiVoiceApiClient>((Ref ref) {
  if (ref.watch(useAiVoiceMockProvider)) {
    return MockAiVoiceApiClient();
  }

  final FunctionsService functionsService = ref.watch(functionsServiceProvider);
  return FirebaseAiVoiceApiClient(functionsService: functionsService);
});

final Provider<AiVoiceRepository> aiVoiceRepositoryProvider = Provider<AiVoiceRepository>((Ref ref) {
  return AiVoiceRepositoryImpl(apiClient: ref.watch(aiVoiceApiClientProvider));
});

final Provider<AudioRecorder> audioRecorderProvider = Provider<AudioRecorder>((Ref ref) {
  return FlutterAudioRecorder();
});

final Provider<AudioPlayer> audioPlayerProvider = Provider<AudioPlayer>((Ref ref) {
  return FlutterAudioPlayer();
});

final ChangeNotifierProvider<VoiceTurnController> voiceTurnControllerProvider =
    ChangeNotifierProvider<VoiceTurnController>((Ref ref) {
      final VoiceTurnController controller = VoiceTurnController(
        repository: ref.watch(aiVoiceRepositoryProvider),
        recorder: ref.watch(audioRecorderProvider),
        player: ref.watch(audioPlayerProvider),
        localStorage: ref.watch(localStorageProvider),
      );

      ref.onDispose(controller.dispose);
      return controller;
    });

final Provider<VoiceTurnState> voiceTurnStateProvider = Provider<VoiceTurnState>((Ref ref) {
  return ref.watch(voiceTurnControllerProvider).state;
});
