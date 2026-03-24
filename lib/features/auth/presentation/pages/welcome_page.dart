import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Spacer(),
          const SectionHeader(
            title: 'Bienvenido a NutriFit',
            subtitle:
                'Tu base de nutrición, ejercicio y bienestar con asistencia de AI.',
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Iniciar sesión',
            onPressed: () => context.go(AppRoutePaths.login),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Crear cuenta',
            isSecondary: true,
            onPressed: () => context.go(AppRoutePaths.register),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
