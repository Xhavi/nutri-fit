import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase/firebase_service_providers.dart';
import '../../../../core/services/functions/functions_service.dart';
import '../../../auth/presentation/controllers/session_providers.dart';
import '../../../exercise/presentation/controllers/exercise_providers.dart';
import '../../../nutrition/presentation/controllers/nutrition_providers.dart';
import '../../../profile/data/health_profile_repository.dart';
import '../../data/clients/ai_coach_api_client.dart';
import '../../data/clients/firebase_ai_coach_api_client.dart';
import '../../data/clients/mock_ai_coach_api_client.dart';
import '../../data/repositories/ai_coach_repository_impl.dart';
import '../../domain/repositories/ai_coach_repository.dart';
import 'ai_coach_controller.dart';
import 'ai_coach_state.dart';

final Provider<bool> aiCoachForceMockProvider = Provider<bool>((Ref ref) {
  return const bool.fromEnvironment('AI_COACH_USE_MOCK', defaultValue: false);
});

final Provider<bool> useAiCoachMockProvider = Provider<bool>((Ref ref) {
  return ref.watch(aiCoachForceMockProvider) || ref.watch(useFirebaseMocksProvider);
});

final Provider<HealthProfileRepository> healthProfileRepositoryProvider =
    Provider<HealthProfileRepository>((Ref ref) {
      return HealthProfileRepository(localStorage: ref.watch(localStorageProvider));
    });

final Provider<AiCoachApiClient> aiCoachApiClientProvider = Provider<AiCoachApiClient>((Ref ref) {
  if (ref.watch(useAiCoachMockProvider)) {
    return MockAiCoachApiClient();
  }

  final FunctionsService functionsService = ref.watch(functionsServiceProvider);
  return FirebaseAiCoachApiClient(functionsService: functionsService);
});

final Provider<AiCoachRepository> aiCoachRepositoryProvider = Provider<AiCoachRepository>((Ref ref) {
  return AiCoachRepositoryImpl(apiClient: ref.watch(aiCoachApiClientProvider));
});

final ChangeNotifierProvider<AiCoachController> aiCoachControllerProvider =
    ChangeNotifierProvider<AiCoachController>((Ref ref) {
      final AiCoachController controller = AiCoachController(
        repository: ref.watch(aiCoachRepositoryProvider),
        profileRepository: ref.watch(healthProfileRepositoryProvider),
        getNutritionState: () => ref.read(nutritionStateProvider),
        getExerciseState: () => ref.read(exerciseStateProvider),
        getSessionState: () => ref.read(sessionStateProvider),
        usesMockBackend: ref.read(useAiCoachMockProvider),
      );

      ref.onDispose(controller.dispose);
      return controller;
    });

final Provider<AiCoachState> aiCoachStateProvider = Provider<AiCoachState>((Ref ref) {
  return ref.watch(aiCoachControllerProvider).state;
});
