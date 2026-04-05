import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/features/profile/presentation/pages/edit_health_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('EditHealthProfilePage shows friendly labels for enums',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'health_profile_v1': jsonEncode(<String, dynamic>{
        'userProfile': <String, dynamic>{
          'name': 'QA Labels',
          'age': 29,
          'sex': 'male',
          'heightCm': 180.0,
          'weightKg': 82.0,
          'activityLevel': 'moderatelyActive',
        },
        'goals': <String, dynamic>{
          'primaryGoal': 'loseWeight',
          'targetWeightKg': 76.0,
        },
        'nutritionPreferences': <String, dynamic>{
          'dietaryPreference': 'omnivore',
          'restrictions': <String>['lactoseIntolerance'],
        },
      }),
    });

    await tester.pumpWidget(
      const MaterialApp(home: EditHealthProfilePage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Masculino'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('Omnivora'), findsOneWidget);
    expect(find.text('Intolerancia a la lactosa'), findsOneWidget);
  });

  testWidgets('EditHealthProfilePage accepts decimal commas when saving',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const MaterialApp(home: EditHealthProfilePage()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'QA Decimal');
    await tester.enterText(find.byType(TextField).at(1), '30');
    await tester.enterText(find.byType(TextField).at(2), '170,5');
    await tester.enterText(find.byType(TextField).at(3), '72,5');
    await tester.enterText(find.byType(TextField).at(4), '68,0');

    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar perfil'));
    await tester.pumpAndSettle();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rawProfile = prefs.getString('health_profile_v1');
    final Map<String, dynamic> json =
        jsonDecode(rawProfile!) as Map<String, dynamic>;

    final Map<String, dynamic> userProfile =
        json['userProfile'] as Map<String, dynamic>;
    final Map<String, dynamic> goals = json['goals'] as Map<String, dynamic>;

    expect(userProfile['name'], 'QA Decimal');
    expect(userProfile['heightCm'], 170.5);
    expect(userProfile['weightKg'], 72.5);
    expect(goals['targetWeightKg'], 68.0);
  });
}
