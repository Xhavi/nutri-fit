import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/features/profile/domain/models/health_profile_models.dart';
import 'package:nutri_fit/features/profile/presentation/pages/goals_review_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GoalsReviewPage shows empty state for incomplete profiles',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'health_profile_v1': jsonEncode(
        const WellnessProfile(
          userProfile: UserHealthProfile(
            name: '',
            age: 0,
            sex: BiologicalSex.other,
            heightCm: 0,
            weightKg: 0,
            activityLevel: ActivityLevel.sedentary,
          ),
          goals: HealthGoals(primaryGoal: PrimaryWellnessGoal.maintainWeight),
          nutritionPreferences: NutritionPreferences(
            dietaryPreference: DietaryPreference.omnivore,
            restrictions: <DietaryRestriction>[],
          ),
        ).toJson(),
      ),
    });

    await tester.pumpWidget(
      const MaterialApp(home: GoalsReviewPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Perfil incompleto'), findsOneWidget);
    expect(
      find.textContaining('Completa nombre, edad, altura y peso'),
      findsOneWidget,
    );
  });

  testWidgets('GoalsReviewPage renders calculations for complete profiles',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'health_profile_v1': jsonEncode(
        const WellnessProfile(
          userProfile: UserHealthProfile(
            name: 'QA Profile',
            age: 30,
            sex: BiologicalSex.female,
            heightCm: 165,
            weightKg: 62,
            activityLevel: ActivityLevel.moderatelyActive,
          ),
          goals: HealthGoals(
            primaryGoal: PrimaryWellnessGoal.loseWeight,
            targetWeightKg: 58,
          ),
          nutritionPreferences: NutritionPreferences(
            dietaryPreference: DietaryPreference.omnivore,
            restrictions: <DietaryRestriction>[DietaryRestriction.glutenFree],
          ),
        ).toJson(),
      ),
    });

    await tester.pumpWidget(
      const MaterialApp(home: GoalsReviewPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Perfil: QA Profile'), findsOneWidget);
    expect(find.textContaining('Objetivo principal:'), findsOneWidget);
    expect(find.textContaining('IMC:'), findsOneWidget);
    expect(find.textContaining('Calor'), findsNWidgets(2));
  });
}
