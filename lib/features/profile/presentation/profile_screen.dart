import 'package:flutter/material.dart';

import '../../../shared/layouts/layouts.dart';
import '../../../shared/widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InternalPageLayout(
      title: 'Profile',
      child: EmptyState(
        title: 'Profile placeholder',
        description: 'TODO: Add personal information and account preferences.',
      ),
    );
  }
}
