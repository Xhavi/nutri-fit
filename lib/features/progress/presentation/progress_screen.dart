import 'package:flutter/material.dart';

import '../../../shared/layouts/layouts.dart';
import '../../../shared/widgets/widgets.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InternalPageLayout(
      title: 'Progress',
      child: EmptyState(
        title: 'Progress module placeholder',
        description: 'TODO: Add trends, streaks, and milestone tracking visuals.',
      ),
    );
  }
}
