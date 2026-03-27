import '../enums/exercise_intensity.dart';

class ActivityEntry {
  const ActivityEntry({
    required this.name,
    required this.duration,
    required this.intensity,
    this.steps,
    this.notes,
  });

  final String name;
  final Duration duration;
  final ExerciseIntensity intensity;
  final int? steps;
  final String? notes;

  /// Estimación simple para actividad general no estructurada.
  ///
  /// Se usa MET base de caminata/actividad ligera (3.3) ajustado por intensidad.
  double estimatedCalories({required double weightKg}) {
    const double baseMet = 3.3;
    final double durationHours = duration.inMinutes / 60;
    return baseMet * intensity.metMultiplier * weightKg * durationHours;
  }

  ActivityEntry copyWith({
    String? name,
    Duration? duration,
    ExerciseIntensity? intensity,
    int? steps,
    String? notes,
  }) {
    return ActivityEntry(
      name: name ?? this.name,
      duration: duration ?? this.duration,
      intensity: intensity ?? this.intensity,
      steps: steps ?? this.steps,
      notes: notes ?? this.notes,
    );
  }
}
