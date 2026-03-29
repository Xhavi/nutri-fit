import 'package:uuid/uuid.dart';

import 'package:nutri_fit/core/utils/date_time_utils.dart';

import '../../domain/entities/activity_entry.dart';
import '../../domain/entities/exercise_entry.dart';
import '../../domain/entities/workout.dart';
import '../../domain/enums/exercise_category.dart';
import '../../domain/enums/exercise_intensity.dart';
import '../../domain/repositories/exercise_repository.dart';

class MockExerciseRepository implements ExerciseRepository {
  MockExerciseRepository() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTimeUtils.normalizeDate(now);

    _workouts = <Workout>[
      Workout(
        id: _uuid.v4(),
        title: 'Entrenamiento de fuerza superior',
        date: today,
        exercises: <ExerciseEntry>[
          const ExerciseEntry(
            name: 'Flexiones',
            category: ExerciseCategory.strength,
            duration: Duration(minutes: 18),
            intensity: ExerciseIntensity.moderate,
          ),
          const ExerciseEntry(
            name: 'Remo con banda',
            category: ExerciseCategory.strength,
            duration: Duration(minutes: 15),
            intensity: ExerciseIntensity.moderate,
          ),
        ],
        activities: const <ActivityEntry>[
          ActivityEntry(
            name: 'Caminata de enfriamiento',
            duration: Duration(minutes: 12),
            intensity: ExerciseIntensity.low,
          ),
        ],
      ),
      Workout(
        id: _uuid.v4(),
        title: 'Cardio base',
        date: today.subtract(const Duration(days: 1)),
        exercises: const <ExerciseEntry>[
          ExerciseEntry(
            name: 'Trote suave',
            category: ExerciseCategory.cardio,
            duration: Duration(minutes: 30),
            intensity: ExerciseIntensity.moderate,
          ),
        ],
      ),
    ];
  }

  final Uuid _uuid = const Uuid();
  late List<Workout> _workouts;

  @override
  Future<void> deleteWorkout(String workoutId) async {
    _workouts = _workouts.where((Workout workout) => workout.id != workoutId).toList();
  }

  @override
  Future<DailyActivitySummary> getDailySummary({
    required DateTime date,
    required double weightKg,
  }) async {
    final List<Workout> workouts = await getWorkoutsForDate(date);
    final int totalMinutes = workouts.fold<int>(
      0,
      (int total, Workout workout) => total + workout.totalDuration.inMinutes,
    );
    final double calories = workouts.fold<double>(
      0,
      (double total, Workout workout) => total + workout.estimatedCalories(weightKg: weightKg),
    );

    return DailyActivitySummary(
      date: _normalizeDate(date),
      totalMinutes: totalMinutes,
      estimatedCalories: calories,
      workoutCount: workouts.length,
    );
  }

  @override
  Future<List<Workout>> getRecentWorkouts({int limit = 20}) async {
    final List<Workout> sorted = <Workout>[..._workouts]
      ..sort((Workout a, Workout b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  @override
  Future<List<Workout>> getWorkoutsForDate(DateTime date) async {
    final DateTime normalized = _normalizeDate(date);
    final List<Workout> entries = _workouts
        .where((Workout workout) => _normalizeDate(workout.date) == normalized)
        .toList()
      ..sort((Workout a, Workout b) => b.totalDuration.inMinutes.compareTo(a.totalDuration.inMinutes));
    return entries;
  }

  @override
  Future<void> saveWorkout(Workout workout) async {
    final bool exists = _workouts.any((Workout existing) => existing.id == workout.id);
    if (!exists) {
      _workouts = <Workout>[..._workouts, workout.copyWith(id: _uuid.v4())];
      return;
    }

    _workouts = _workouts
        .map((Workout existing) => existing.id == workout.id ? workout : existing)
        .toList();
  }

  DateTime _normalizeDate(DateTime date) => DateTimeUtils.normalizeDate(date);
}
