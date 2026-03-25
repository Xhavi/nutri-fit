import '../domain/models/health_profile_models.dart';

class WellnessCalculationResult {
  const WellnessCalculationResult({
    required this.bmi,
    required this.bmiLabel,
    required this.maintenanceCalories,
    required this.targetCalories,
    required this.targetProteinGrams,
    required this.targetCarbsGrams,
    required this.targetFatGrams,
    required this.simpleGoalNotes,
    required this.warnings,
  });

  final double bmi;
  final String bmiLabel;
  final int maintenanceCalories;
  final int targetCalories;
  final int targetProteinGrams;
  final int targetCarbsGrams;
  final int targetFatGrams;
  final List<String> simpleGoalNotes;
  final List<String> warnings;
}

class WellnessCalculationService {
  WellnessCalculationResult calculate(WellnessProfile profile) {
    final UserHealthProfile user = profile.userProfile;
    final HealthGoals goals = profile.goals;

    final double bmi = user.weightKg / (user.safeHeightMeters * user.safeHeightMeters);

    final double bmr = _estimateBmr(user);
    final int maintenance = (bmr * user.activityLevel.multiplier).round();
    final int calories = _targetCalories(maintenance, goals.primaryGoal);
    final _MacroSplit split = _macroSplit(goals.primaryGoal);

    final int proteinGrams = ((calories * split.proteinPct) / 4).round();
    final int carbsGrams = ((calories * split.carbsPct) / 4).round();
    final int fatGrams = ((calories * split.fatPct) / 9).round();

    return WellnessCalculationResult(
      bmi: bmi,
      bmiLabel: _bmiLabel(bmi),
      maintenanceCalories: maintenance,
      targetCalories: calories,
      targetProteinGrams: proteinGrams,
      targetCarbsGrams: carbsGrams,
      targetFatGrams: fatGrams,
      simpleGoalNotes: _simpleGoalNotes(profile),
      warnings: _warnings(profile, calories),
    );
  }

  double _estimateBmr(UserHealthProfile user) {
    final double base = (10 * user.weightKg) + (6.25 * user.heightCm) - (5 * user.age);

    switch (user.sex) {
      case BiologicalSex.female:
        return base - 161;
      case BiologicalSex.male:
        return base + 5;
      case BiologicalSex.other:
        return base - 78;
    }
  }

  int _targetCalories(int maintenanceCalories, PrimaryWellnessGoal goal) {
    final int rawTarget;

    switch (goal) {
      case PrimaryWellnessGoal.loseWeight:
        rawTarget = maintenanceCalories - 350;
      case PrimaryWellnessGoal.maintainWeight:
        rawTarget = maintenanceCalories;
      case PrimaryWellnessGoal.gainMuscle:
        rawTarget = maintenanceCalories + 250;
      case PrimaryWellnessGoal.improveHabits:
        rawTarget = maintenanceCalories;
    }

    return rawTarget.clamp(1200, 4000);
  }

  String _bmiLabel(double bmi) {
    if (bmi < 18.5) {
      return 'Bajo peso';
    }
    if (bmi < 25) {
      return 'Rango saludable';
    }
    if (bmi < 30) {
      return 'Sobrepeso';
    }
    return 'Obesidad';
  }

  _MacroSplit _macroSplit(PrimaryWellnessGoal goal) {
    switch (goal) {
      case PrimaryWellnessGoal.loseWeight:
        return const _MacroSplit(proteinPct: 0.35, carbsPct: 0.35, fatPct: 0.30);
      case PrimaryWellnessGoal.maintainWeight:
        return const _MacroSplit(proteinPct: 0.30, carbsPct: 0.40, fatPct: 0.30);
      case PrimaryWellnessGoal.gainMuscle:
        return const _MacroSplit(proteinPct: 0.30, carbsPct: 0.45, fatPct: 0.25);
      case PrimaryWellnessGoal.improveHabits:
        return const _MacroSplit(proteinPct: 0.25, carbsPct: 0.45, fatPct: 0.30);
    }
  }

  List<String> _simpleGoalNotes(WellnessProfile profile) {
    final List<String> notes = <String>[];
    final HealthGoals goals = profile.goals;

    notes.add('Prioriza constancia semanal: comidas completas, agua y sueño regular.');

    if (goals.targetWeightKg != null) {
      final double diff = goals.targetWeightKg! - profile.userProfile.weightKg;
      final String direction = diff >= 0 ? 'subir' : 'bajar';
      notes.add('Meta declarada: $direction hacia ${goals.targetWeightKg!.toStringAsFixed(1)} kg.');
    }

    switch (goals.primaryGoal) {
      case PrimaryWellnessGoal.loseWeight:
        notes.add('Objetivo simple: déficit moderado y actividad diaria sin extremos.');
      case PrimaryWellnessGoal.maintainWeight:
        notes.add('Objetivo simple: mantener peso y reforzar hábitos sostenibles.');
      case PrimaryWellnessGoal.gainMuscle:
        notes.add('Objetivo simple: superávit controlado y entrenamiento de fuerza progresivo.');
      case PrimaryWellnessGoal.improveHabits:
        notes.add('Objetivo simple: adherencia y calidad alimentaria antes que cambios agresivos.');
    }

    return notes;
  }

  List<String> _warnings(WellnessProfile profile, int targetCalories) {
    final List<String> warnings = <String>[
      'Esto es guía de bienestar general, no diagnóstico ni tratamiento médico.',
      'TODO: agregar evaluación de casos sensibles (embarazo, lactancia, historial clínico).',
      'TODO: derivar a profesional cuando haya señales de riesgo o trastorno alimentario.',
    ];

    if (targetCalories <= 1300 || targetCalories >= 3800) {
      warnings.add('Se aplicaron límites de seguridad para evitar recomendaciones extremas.');
    }

    if (profile.userProfile.age < 18) {
      warnings.add('Para menores de edad, usar revisión profesional antes de aplicar objetivos.');
    }

    if (profile.nutritionPreferences.restrictions.length >= 3) {
      warnings.add('Múltiples restricciones alimentarias: conviene validación profesional.');
    }

    return warnings;
  }
}

class _MacroSplit {
  const _MacroSplit({
    required this.proteinPct,
    required this.carbsPct,
    required this.fatPct,
  });

  final double proteinPct;
  final double carbsPct;
  final double fatPct;
}
