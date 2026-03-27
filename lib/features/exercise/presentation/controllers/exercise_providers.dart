import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_exercise_repository.dart';
import '../../domain/repositories/exercise_repository.dart';
import 'exercise_controller.dart';
import 'exercise_state.dart';

final Provider<ExerciseRepository> exerciseRepositoryProvider = Provider<ExerciseRepository>(
  (Ref ref) => MockExerciseRepository(),
);

final ChangeNotifierProvider<ExerciseController> exerciseControllerProvider =
    ChangeNotifierProvider<ExerciseController>((Ref ref) {
      final ExerciseController controller = ExerciseController(
        repository: ref.watch(exerciseRepositoryProvider),
      );
      controller.initialize();
      ref.onDispose(controller.dispose);
      return controller;
    });

final Provider<ExerciseState> exerciseStateProvider = Provider<ExerciseState>((Ref ref) {
  return ref.watch(exerciseControllerProvider).state;
});
