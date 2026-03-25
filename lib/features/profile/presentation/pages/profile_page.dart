import 'package:flutter/material.dart';

import '../../../../shared/layouts/internal_base_layout.dart';
import '../../../../shared/widgets/app_button.dart';
import 'edit_health_profile_page.dart';
import 'goals_review_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return InternalBaseLayout(
      title: 'Perfil',
      currentIndex: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Personalización de salud', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            'Configura perfil, metas y preferencias para construir objetivos de wellness base.',
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Editar perfil de salud',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const EditHealthProfilePage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Revisar objetivos y cálculo',
            isSecondary: true,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const GoalsReviewPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Nota: NutriFit ofrece guía de bienestar general. No realiza diagnóstico médico.',
          ),
        ],
      ),
    );
  }
}
