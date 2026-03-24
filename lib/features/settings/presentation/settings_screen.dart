import 'package:flutter/material.dart';

import '../../../shared/layouts/layouts.dart';
import '../../../shared/widgets/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InternalPageLayout(
      title: 'Settings',
      child: EmptyState(
        title: 'Settings placeholder',
        description: 'TODO: Add notifications, privacy, and preference management.',
      ),
    );
  }
}
