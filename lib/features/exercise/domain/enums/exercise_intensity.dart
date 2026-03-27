enum ExerciseIntensity { low, moderate, high }

extension ExerciseIntensityX on ExerciseIntensity {
  String get label {
    switch (this) {
      case ExerciseIntensity.low:
        return 'Baja';
      case ExerciseIntensity.moderate:
        return 'Moderada';
      case ExerciseIntensity.high:
        return 'Alta';
    }
  }

  /// Multiplicador simple sobre MET base para ajustar intensidad.
  double get metMultiplier {
    switch (this) {
      case ExerciseIntensity.low:
        return 0.85;
      case ExerciseIntensity.moderate:
        return 1.0;
      case ExerciseIntensity.high:
        return 1.2;
    }
  }
}
