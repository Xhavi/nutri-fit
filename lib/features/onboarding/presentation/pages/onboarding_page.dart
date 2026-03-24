import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Onboarding',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHeader(
            title: 'Configura tu experiencia',
            subtitle: 'Definiremos objetivos, hábitos y preferencias clave.',
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'TODO: Reemplazar este placeholder por flujo real de onboarding por pasos.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const Spacer(),
          AppButton(
            label: 'Ir al panel',
            onPressed: () => context.go(AppRoutePaths.home),
          ),
        ],
      ),
    );
  }
}
