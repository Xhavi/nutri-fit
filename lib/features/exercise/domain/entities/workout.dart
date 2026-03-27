import 'activity_entry.dart';
import 'exercise_entry.dart';

class Workout {
  const Workout({
    required this.id,
    required this.title,
    required this.date,
    required this.exercises,
    this.activities = const <ActivityEntry>[],
    this.notes,
  });

  final String id;
  final String title;
  final DateTime date;
  final List<ExerciseEntry> exercises;
  final List<ActivityEntry> activities;
  final String? notes;

  Duration get totalDuration {
    final int exerciseMinutes = exercises.fold<int>(
      0,
      (int total, ExerciseEntry entry) => total + entry.duration.inMinutes,
    );
    final int activityMinutes = activities.fold<int>(
      0,
      (int total, ActivityEntry entry) => total + entry.duration.inMinutes,
    );
    return Duration(minutes: exerciseMinutes + activityMinutes);
  }

  double estimatedCalories({required double weightKg}) {
    final double exerciseCalories = exercises.fold<double>(
      0,
      (double total, ExerciseEntry entry) => total + entry.estimatedCalories(weightKg: weightKg),
    );
    final double activityCalories = activities.fold<double>(
      0,
      (double total, ActivityEntry entry) => total + entry.estimatedCalories(weightKg: weightKg),
    );
    return exerciseCalories + activityCalories;
  }

  Workout copyWith({
    String? id,
    String? title,
    DateTime? date,
    List<ExerciseEntry>? exercises,
    List<ActivityEntry>? activities,
    String? notes,
  }) {
    return Workout(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
      activities: activities ?? this.activities,
      notes: notes ?? this.notes,
    );
  }
}
