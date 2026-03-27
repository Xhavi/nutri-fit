import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_nutrition_repository.dart';
import '../../domain/repositories/nutrition_repository.dart';
import 'nutrition_controller.dart';
import 'nutrition_state.dart';

final Provider<NutritionRepository> nutritionRepositoryProvider = Provider<NutritionRepository>(
  (Ref ref) => MockNutritionRepository(),
);

final ChangeNotifierProvider<NutritionController> nutritionControllerProvider =
    ChangeNotifierProvider<NutritionController>((Ref ref) {
      final NutritionController controller = NutritionController(
        repository: ref.watch(nutritionRepositoryProvider),
      );
      controller.initialize();
      ref.onDispose(controller.dispose);
      return controller;
    });

final Provider<NutritionState> nutritionStateProvider = Provider<NutritionState>((Ref ref) {
  return ref.watch(nutritionControllerProvider).state;
});
