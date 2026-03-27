import '../entities/workout.dart';

class DailyActivitySummary {
  const DailyActivitySummary({
    required this.date,
    required this.totalMinutes,
    required this.estimatedCalories,
    required this.workoutCount,
  });

  final DateTime date;
  final int totalMinutes;
  final double estimatedCalories;
  final int workoutCount;
}

abstract class ExerciseRepository {
  Future<List<Workout>> getWorkoutsForDate(DateTime date);
  Future<List<Workout>> getRecentWorkouts({int limit = 20});
  Future<void> saveWorkout(Workout workout);
  Future<void> deleteWorkout(String workoutId);
  Future<DailyActivitySummary> getDailySummary({
    required DateTime date,
    required double weightKg,
  });
}
