import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/features/auth/presentation/pages/register_page.dart';

void main() {
  testWidgets('RegisterPage blocks empty form submission with a clear message',
      (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: RegisterPage()),
        ),
      ),
    );

    await tester.tap(find.text('Continuar'));
    await tester.pump();

    expect(
        find.text('Ingresa tu nombre para crear la cuenta.'), findsOneWidget);
  });
}
