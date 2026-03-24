import 'package:flutter/material.dart';

import '../../../shared/widgets/widgets.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Onboarding',
      child: EmptyState(
        title: 'Onboarding setup pending',
        description:
            'We will collect preferences, goals, and baseline profile data here.',
        action: AppButton(
          label: 'Continue',
          onPressed: () {},
          icon: Icons.flag_outlined,
        ),
      ),
    );
  }
}
