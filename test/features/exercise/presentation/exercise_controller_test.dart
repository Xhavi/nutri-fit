import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/features/exercise/data/repositories/mock_exercise_repository.dart';
import 'package:nutri_fit/features/exercise/presentation/controllers/exercise_controller.dart';

void main() {
  test('ExerciseController clamps estimated weight and refreshes calories',
      () async {
    final ExerciseController controller = ExerciseController(
      repository: MockExerciseRepository(),
    );

    await controller.initialize();
    final double initialCalories =
        controller.state.dailySummary.estimatedCalories;

    await controller.setEstimatedWeight(500);

    expect(controller.state.estimatedWeightKg, 250);
    expect(
      controller.state.dailySummary.estimatedCalories,
      greaterThan(initialCalories),
    );

    await controller.setEstimatedWeight(10);

    expect(controller.state.estimatedWeightKg, 35);
  });
}
