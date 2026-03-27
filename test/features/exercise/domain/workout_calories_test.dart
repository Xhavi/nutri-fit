import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/features/exercise/domain/entities/exercise_entry.dart';
import 'package:nutri_fit/features/exercise/domain/entities/workout.dart';
import 'package:nutri_fit/features/exercise/domain/enums/exercise_category.dart';
import 'package:nutri_fit/features/exercise/domain/enums/exercise_intensity.dart';

void main() {
  test('calcula calorías estimadas y duración total del workout', () {
    const Workout workout = Workout(
      id: 'w1',
      title: 'Test',
      date: DateTime(2026, 3, 27),
      exercises: <ExerciseEntry>[
        ExerciseEntry(
          name: 'Trote',
          category: ExerciseCategory.cardio,
          duration: Duration(minutes: 30),
          intensity: ExerciseIntensity.moderate,
        ),
      ],
    );

    expect(workout.totalDuration.inMinutes, 30);
    expect(workout.estimatedCalories(weightKg: 70), greaterThan(200));
  });
}
