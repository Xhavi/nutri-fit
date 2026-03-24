import 'package:flutter/material.dart';

import '../../../shared/widgets/widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Spacer(),
          const SectionHeader(
            title: 'Welcome to NutriFit',
            subtitle: 'Nutrition, exercise and AI wellness coaching in one place.',
          ),
          const SizedBox(height: 24),
          // TODO: Connect navigation with auth flow guards.
          AppButton(
            label: 'Get started',
            onPressed: () {},
            icon: Icons.arrow_forward,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            child: const Text('I already have an account'),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
