import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('LoginPage blocks invalid email submission with a clear message',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: LoginPage()),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'correo-invalido');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(
      find.text('Ingresa un correo electronico valido.'),
      findsOneWidget,
    );
  });
}
