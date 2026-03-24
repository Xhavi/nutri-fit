import 'package:flutter/material.dart';

import '../../../shared/widgets/widgets.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create account',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHeader(
            title: 'Start your NutriFit journey',
            subtitle: 'Create your account to personalize your experience.',
          ),
          const SizedBox(height: 16),
          const AppTextField(label: 'Name'),
          const SizedBox(height: 12),
          const AppTextField(label: 'Email'),
          const SizedBox(height: 12),
          const AppTextField(label: 'Password', obscureText: true),
          const SizedBox(height: 24),
          // TODO: Wire registration flow to backend auth service.
          AppButton(label: 'Create account', onPressed: () {}),
        ],
      ),
    );
  }
}
