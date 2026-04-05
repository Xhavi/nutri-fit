import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/features/nutrition/presentation/pages/add_edit_meal_page.dart';

void main() {
  testWidgets('AddEditMealPage shows feedback when food name is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AddEditMealPage(selectedDate: DateTime(2026, 4, 5)),
        ),
      ),
    );

    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(
      find.text('Ingresa al menos un alimento para guardar la comida.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'AddEditMealPage blocks negative calories and macros',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AddEditMealPage(selectedDate: DateTime(2026, 4, 5)),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), 'Yogur');
      await tester.enterText(find.byType(TextField).at(1), '-120');
      await tester.enterText(find.byType(TextField).at(2), '10');
      await tester.enterText(find.byType(TextField).at(3), '8');
      await tester.enterText(find.byType(TextField).at(4), '4');

      await tester.tap(find.text('Guardar'));
      await tester.pump();

      expect(
        find.text('Las calorias y macros no pueden ser negativas.'),
        findsOneWidget,
      );
    },
  );
}
