enum ExerciseCategory {
  strength,
  cardio,
  mobility,
  sports,
  functional,
  recovery,
}

extension ExerciseCategoryX on ExerciseCategory {
  String get label {
    switch (this) {
      case ExerciseCategory.strength:
        return 'Fuerza';
      case ExerciseCategory.cardio:
        return 'Cardio';
      case ExerciseCategory.mobility:
        return 'Movilidad';
      case ExerciseCategory.sports:
        return 'Deporte';
      case ExerciseCategory.functional:
        return 'Funcional';
      case ExerciseCategory.recovery:
        return 'Recuperación';
    }
  }

  /// Base MET (Metabolic Equivalent of Task) simplificado por categoría.
  ///
  /// Referencia de fórmula simple usada en este módulo:
  /// kcal = MET * pesoKg * duraciónHoras
  ///
  /// Estos valores son aproximados y se usan como guía de bienestar general,
  /// no como medición clínica.
  double get baseMet {
    switch (this) {
      case ExerciseCategory.strength:
        return 5.5;
      case ExerciseCategory.cardio:
        return 7.0;
      case ExerciseCategory.mobility:
        return 3.0;
      case ExerciseCategory.sports:
        return 6.5;
      case ExerciseCategory.functional:
        return 6.0;
      case ExerciseCategory.recovery:
        return 2.0;
    }
  }
}
