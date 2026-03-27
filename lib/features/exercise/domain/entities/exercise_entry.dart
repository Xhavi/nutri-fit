import '../enums/exercise_category.dart';
import '../enums/exercise_intensity.dart';

class ExerciseEntry {
  const ExerciseEntry({
    required this.name,
    required this.category,
    required this.duration,
    required this.intensity,
    this.notes,
  });

  final String name;
  final ExerciseCategory category;
  final Duration duration;
  final ExerciseIntensity intensity;
  final String? notes;

  /// Estimación simple de calorías para una entrada de ejercicio.
  ///
  /// Fórmula documentada:
  /// kcal = (MET base categoría * multiplicador intensidad) * pesoKg * horas
  double estimatedCalories({required double weightKg}) {
    final double durationHours = duration.inMinutes / 60;
    final double met = category.baseMet * intensity.metMultiplier;
    return met * weightKg * durationHours;
  }

  ExerciseEntry copyWith({
    String? name,
    ExerciseCategory? category,
    Duration? duration,
    ExerciseIntensity? intensity,
    String? notes,
  }) {
    return ExerciseEntry(
      name: name ?? this.name,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
    );
  }
}
