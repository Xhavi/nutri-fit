import 'dart:math';

enum BiologicalSex { female, male, other }

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extraActive,
}

enum PrimaryWellnessGoal { loseWeight, maintainWeight, gainMuscle, improveHabits }

enum DietaryPreference { omnivore, vegetarian, vegan, pescatarian, keto }

enum DietaryRestriction {
  lactoseIntolerance,
  glutenFree,
  nutAllergy,
  shellfishAllergy,
  lowSodium,
}

extension ActivityLevelX on ActivityLevel {
  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
      case ActivityLevel.extraActive:
        return 1.9;
    }
  }

  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentario';
      case ActivityLevel.lightlyActive:
        return 'Ligera actividad';
      case ActivityLevel.moderatelyActive:
        return 'Actividad moderada';
      case ActivityLevel.veryActive:
        return 'Muy activo';
      case ActivityLevel.extraActive:
        return 'Extremadamente activo';
    }
  }
}

extension PrimaryWellnessGoalX on PrimaryWellnessGoal {
  String get label {
    switch (this) {
      case PrimaryWellnessGoal.loseWeight:
        return 'Pérdida de grasa';
      case PrimaryWellnessGoal.maintainWeight:
        return 'Mantenimiento';
      case PrimaryWellnessGoal.gainMuscle:
        return 'Ganancia muscular';
      case PrimaryWellnessGoal.improveHabits:
        return 'Mejora de hábitos';
    }
  }
}

class UserHealthProfile {
  const UserHealthProfile({
    required this.name,
    required this.age,
    required this.sex,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
  });

  final String name;
  final int age;
  final BiologicalSex sex;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;

  double get safeHeightMeters => max(heightCm / 100, 0.01);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'age': age,
    'sex': sex.name,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'activityLevel': activityLevel.name,
  };

  factory UserHealthProfile.fromJson(Map<String, dynamic> json) {
    return UserHealthProfile(
      name: json['name'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      sex: _enumByName(BiologicalSex.values, json['sex'] as String?, BiologicalSex.other),
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
      activityLevel: _enumByName(
        ActivityLevel.values,
        json['activityLevel'] as String?,
        ActivityLevel.sedentary,
      ),
    );
  }
}

class HealthGoals {
  const HealthGoals({required this.primaryGoal, this.targetWeightKg});

  final PrimaryWellnessGoal primaryGoal;
  final double? targetWeightKg;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'primaryGoal': primaryGoal.name,
    'targetWeightKg': targetWeightKg,
  };

  factory HealthGoals.fromJson(Map<String, dynamic> json) {
    return HealthGoals(
      primaryGoal: _enumByName(
        PrimaryWellnessGoal.values,
        json['primaryGoal'] as String?,
        PrimaryWellnessGoal.maintainWeight,
      ),
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
    );
  }
}

class NutritionPreferences {
  const NutritionPreferences({
    required this.dietaryPreference,
    required this.restrictions,
  });

  final DietaryPreference dietaryPreference;
  final List<DietaryRestriction> restrictions;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'dietaryPreference': dietaryPreference.name,
    'restrictions': restrictions.map((DietaryRestriction r) => r.name).toList(),
  };

  factory NutritionPreferences.fromJson(Map<String, dynamic> json) {
    final List<dynamic> restrictionValues =
        json['restrictions'] as List<dynamic>? ?? <dynamic>[];

    return NutritionPreferences(
      dietaryPreference: _enumByName(
        DietaryPreference.values,
        json['dietaryPreference'] as String?,
        DietaryPreference.omnivore,
      ),
      restrictions: restrictionValues
          .whereType<String>()
          .map(
            (String value) =>
                _enumByName(DietaryRestriction.values, value, DietaryRestriction.lowSodium),
          )
          .toList(),
    );
  }
}

class WellnessProfile {
  const WellnessProfile({
    required this.userProfile,
    required this.goals,
    required this.nutritionPreferences,
  });

  final UserHealthProfile userProfile;
  final HealthGoals goals;
  final NutritionPreferences nutritionPreferences;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'userProfile': userProfile.toJson(),
    'goals': goals.toJson(),
    'nutritionPreferences': nutritionPreferences.toJson(),
  };

  factory WellnessProfile.fromJson(Map<String, dynamic> json) {
    return WellnessProfile(
      userProfile: UserHealthProfile.fromJson(
        json['userProfile'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      goals: HealthGoals.fromJson(
        json['goals'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      nutritionPreferences: NutritionPreferences.fromJson(
        json['nutritionPreferences'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }
}

T _enumByName<T extends Enum>(List<T> values, String? raw, T fallback) {
  return values.firstWhere((T value) => value.name == raw, orElse: () => fallback);
}
