import '../../../core/services/local_storage_service.dart';
import '../../onboarding/domain/onboarding_profile.dart';
import '../domain/models/health_profile_models.dart';

class HealthProfileRepository {
  HealthProfileRepository({required LocalStorageService localStorage})
      : _localStorage = localStorage;

  final LocalStorageService _localStorage;
  static const String _profileKey = 'health_profile_v1';

  Future<void> saveProfile(WellnessProfile profile) async {
    await _localStorage.setJson(_profileKey, profile.toJson());
  }

  Future<void> saveFromOnboardingProfile(OnboardingProfile profile) async {
    await saveProfile(
      WellnessProfile(
        userProfile: UserHealthProfile(
          name: profile.name.trim(),
          age: profile.age,
          sex: _mapSex(profile.sex),
          heightCm: profile.heightCm,
          weightKg: profile.weightKg,
          activityLevel: _mapActivityLevel(profile.activityLevel),
        ),
        goals: HealthGoals(
          primaryGoal: _mapPrimaryGoal(profile.primaryGoal),
        ),
        nutritionPreferences: NutritionPreferences(
          dietaryPreference: _mapDietaryPreference(profile.foodRestrictions),
          restrictions: _mapRestrictions(profile.foodRestrictions),
        ),
      ),
    );
  }

  Future<WellnessProfile?> loadProfile() async {
    final Map<String, dynamic>? json = await _localStorage.getJson(_profileKey);
    if (json == null) {
      return null;
    }

    return WellnessProfile.fromJson(json);
  }

  Future<void> clearProfile() async {
    await _localStorage.remove(_profileKey);
  }

  BiologicalSex _mapSex(String value) {
    switch (value.trim().toLowerCase()) {
      case 'femenino':
        return BiologicalSex.female;
      case 'masculino':
        return BiologicalSex.male;
      default:
        return BiologicalSex.other;
    }
  }

  ActivityLevel _mapActivityLevel(String value) {
    switch (value.trim().toLowerCase()) {
      case 'bajo':
        return ActivityLevel.sedentary;
      case 'moderado':
        return ActivityLevel.moderatelyActive;
      case 'alto':
        return ActivityLevel.veryActive;
      case 'muy alto':
        return ActivityLevel.extraActive;
      default:
        return ActivityLevel.sedentary;
    }
  }

  PrimaryWellnessGoal _mapPrimaryGoal(String value) {
    switch (value.trim().toLowerCase()) {
      case 'perder grasa':
        return PrimaryWellnessGoal.loseWeight;
      case 'ganar masa muscular':
        return PrimaryWellnessGoal.gainMuscle;
      case 'mejorar energía diaria':
      case 'mejorar energia diaria':
        return PrimaryWellnessGoal.improveHabits;
      case 'mantener peso':
      default:
        return PrimaryWellnessGoal.maintainWeight;
    }
  }

  DietaryPreference _mapDietaryPreference(String value) {
    final String normalized = value.trim().toLowerCase();
    if (normalized.contains('vegano') || normalized.contains('vegan')) {
      return DietaryPreference.vegan;
    }
    if (normalized.contains('vegetar')) {
      return DietaryPreference.vegetarian;
    }
    if (normalized.contains('pesc')) {
      return DietaryPreference.pescatarian;
    }
    if (normalized.contains('keto')) {
      return DietaryPreference.keto;
    }

    return DietaryPreference.omnivore;
  }

  List<DietaryRestriction> _mapRestrictions(String value) {
    final String normalized = value.toLowerCase();
    final List<DietaryRestriction> restrictions = <DietaryRestriction>[];

    if (normalized.contains('lactosa')) {
      restrictions.add(DietaryRestriction.lactoseIntolerance);
    }
    if (normalized.contains('gluten')) {
      restrictions.add(DietaryRestriction.glutenFree);
    }
    if (normalized.contains('nuez') || normalized.contains('nuts')) {
      restrictions.add(DietaryRestriction.nutAllergy);
    }
    if (normalized.contains('marisco')) {
      restrictions.add(DietaryRestriction.shellfishAllergy);
    }
    if (normalized.contains('sodio')) {
      restrictions.add(DietaryRestriction.lowSodium);
    }

    return restrictions;
  }
}
