import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/features/home/presentation/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HomePage uses saved health profile data for greeting and goal',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'health_profile_v1': jsonEncode(<String, dynamic>{
        'userProfile': <String, dynamic>{
          'name': 'Juan QA',
          'age': 31,
          'sex': 'male',
          'heightCm': 176.0,
          'weightKg': 78.5,
          'activityLevel': 'moderatelyActive',
        },
        'goals': <String, dynamic>{
          'primaryGoal': 'loseWeight',
          'targetWeightKg': 74.0,
        },
        'nutritionPreferences': <String, dynamic>{
          'dietaryPreference': 'omnivore',
          'restrictions': <String>[],
        },
      }),
    });

    await tester.pumpWidget(
      const MaterialApp(home: HomePage()),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Juan QA'), findsOneWidget);
    expect(
      find.text('Deficit moderado para perdida de grasa'),
      findsOneWidget,
    );
  });
}
