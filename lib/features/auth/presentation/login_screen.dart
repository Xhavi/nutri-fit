import 'package:flutter/material.dart';

import '../../../shared/widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Login',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHeader(
            title: 'Welcome back',
            subtitle: 'Sign in to continue your wellness journey.',
          ),
          const SizedBox(height: 16),
          const AppTextField(label: 'Email', hint: 'name@email.com'),
          const SizedBox(height: 12),
          const AppTextField(label: 'Password', obscureText: true),
          const SizedBox(height: 24),
          // TODO: Wire login action to real authentication provider.
          AppButton(label: 'Sign in', onPressed: () {}),
        ],
      ),
    );
  }
}
