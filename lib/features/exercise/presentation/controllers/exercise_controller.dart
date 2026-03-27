import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/activity_entry.dart';
import '../../domain/entities/exercise_entry.dart';
import '../../domain/entities/workout.dart';
import '../../domain/enums/exercise_category.dart';
import '../../domain/enums/exercise_intensity.dart';
import '../../domain/repositories/exercise_repository.dart';
import 'exercise_state.dart';

class ExerciseController extends ChangeNotifier {
  ExerciseController({required ExerciseRepository repository}) : _repository = repository;

  final ExerciseRepository _repository;
  final Uuid _uuid = const Uuid();

  ExerciseState _state = ExerciseState.initial();
  ExerciseState get state => _state;

  Future<void> initialize() async {
    await loadForDate(_state.selectedDate);
  }

  Future<void> loadForDate(DateTime date) async {
    final DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    _state = _state.copyWith(isLoading: true, selectedDate: normalizedDate);
    notifyListeners();

    final List<Workout> dayWorkouts = await _repository.getWorkoutsForDate(normalizedDate);
    final List<Workout> history = await _repository.getRecentWorkouts(limit: 30);
    final DailyActivitySummary summary = await _repository.getDailySummary(
      date: normalizedDate,
      weightKg: _state.estimatedWeightKg,
    );

    _state = _state.copyWith(
      dailyWorkouts: dayWorkouts,
      history: history,
      dailySummary: summary,
      isLoading: false,
    );
    notifyListeners();
  }

  Future<void> addWorkout({
    required String title,
    required DateTime date,
    required ExerciseCategory category,
    required int durationMinutes,
    required ExerciseIntensity intensity,
    String? notes,
  }) async {
    final Workout workout = Workout(
      id: _uuid.v4(),
      title: title,
      date: DateTime(date.year, date.month, date.day),
      exercises: <ExerciseEntry>[
        ExerciseEntry(
          name: title,
          category: category,
          duration: Duration(minutes: durationMinutes),
          intensity: intensity,
          notes: notes,
        ),
      ],
      activities: <ActivityEntry>[
        ActivityEntry(
          name: 'Actividad diaria asociada',
          duration: Duration(minutes: (durationMinutes * 0.25).round().clamp(5, 30)),
          intensity: intensity,
        ),
      ],
      notes: notes,
    );

    await _repository.saveWorkout(workout);
    await loadForDate(_state.selectedDate);
  }

  Future<void> deleteWorkout(String workoutId) async {
    await _repository.deleteWorkout(workoutId);
    await loadForDate(_state.selectedDate);
  }

  Future<void> setEstimatedWeight(double weightKg) async {
    _state = _state.copyWith(estimatedWeightKg: weightKg.clamp(35, 250));
    notifyListeners();
    await loadForDate(_state.selectedDate);
  }
}
