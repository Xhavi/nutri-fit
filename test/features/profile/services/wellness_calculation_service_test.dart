import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/features/profile/domain/models/health_profile_models.dart';
import 'package:nutri_fit/features/profile/services/wellness_calculation_service.dart';

void main() {
  final WellnessCalculationService service = WellnessCalculationService();

  WellnessProfile buildProfile({
    PrimaryWellnessGoal goal = PrimaryWellnessGoal.maintainWeight,
    int age = 30,
  }) {
    return WellnessProfile(
      userProfile: UserHealthProfile(
        name: 'Test',
        age: age,
        sex: BiologicalSex.male,
        heightCm: 178,
        weightKg: 80,
        activityLevel: ActivityLevel.moderatelyActive,
      ),
      goals: HealthGoals(primaryGoal: goal, targetWeightKg: 75),
      nutritionPreferences: const NutritionPreferences(
        dietaryPreference: DietaryPreference.omnivore,
        restrictions: <DietaryRestriction>[],
      ),
    );
  }

  group('WellnessCalculationService', () {
    test('calcula IMC y calorías de mantenimiento', () {
      final WellnessCalculationResult result = service.calculate(buildProfile());

      expect(result.bmi, closeTo(25.2, 0.2));
      expect(result.maintenanceCalories, greaterThan(2400));
      expect(result.maintenanceCalories, lessThan(3200));
    });

    test('aplica déficit moderado para pérdida de grasa', () {
      final WellnessCalculationResult result = service.calculate(
        buildProfile(goal: PrimaryWellnessGoal.loseWeight),
      );

      expect(result.targetCalories, lessThan(result.maintenanceCalories));
      expect(result.targetCalories, greaterThanOrEqualTo(1200));
    });

    test('aplica superávit moderado para ganancia muscular', () {
      final WellnessCalculationResult result = service.calculate(
        buildProfile(goal: PrimaryWellnessGoal.gainMuscle),
      );

      expect(result.targetCalories, greaterThan(result.maintenanceCalories));
      expect(result.targetProteinGrams, greaterThan(100));
    });

    test('agrega advertencia para menores de edad', () {
      final WellnessCalculationResult result = service.calculate(buildProfile(age: 16));

      expect(
        result.warnings.any((String warning) => warning.contains('menores de edad')),
        isTrue,
      );
    });
  });
}
