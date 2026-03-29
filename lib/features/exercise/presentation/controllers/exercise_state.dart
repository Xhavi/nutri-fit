import 'package:nutri_fit/core/utils/date_time_utils.dart';

import '../../domain/entities/workout.dart';
import '../../domain/repositories/exercise_repository.dart';

class ExerciseState {
  const ExerciseState({
    required this.selectedDate,
    required this.dailyWorkouts,
    required this.history,
    required this.dailySummary,
    required this.estimatedWeightKg,
    this.isLoading = false,
  });

  final DateTime selectedDate;
  final List<Workout> dailyWorkouts;
  final List<Workout> history;
  final DailyActivitySummary dailySummary;
  final double estimatedWeightKg;
  final bool isLoading;

  ExerciseState copyWith({
    DateTime? selectedDate,
    List<Workout>? dailyWorkouts,
    List<Workout>? history,
    DailyActivitySummary? dailySummary,
    double? estimatedWeightKg,
    bool? isLoading,
  }) {
    return ExerciseState(
      selectedDate: selectedDate ?? this.selectedDate,
      dailyWorkouts: dailyWorkouts ?? this.dailyWorkouts,
      history: history ?? this.history,
      dailySummary: dailySummary ?? this.dailySummary,
      estimatedWeightKg: estimatedWeightKg ?? this.estimatedWeightKg,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory ExerciseState.initial() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTimeUtils.normalizeDate(now);
    return ExerciseState(
      selectedDate: today,
      dailyWorkouts: const <Workout>[],
      history: const <Workout>[],
      estimatedWeightKg: 70,
      dailySummary: DailyActivitySummary(
        date: today,
        totalMinutes: 0,
        estimatedCalories: 0,
        workoutCount: 0,
      ),
    );
  }
}
