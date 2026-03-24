import 'package:flutter/material.dart';

import '../../../shared/layouts/layouts.dart';
import '../../../shared/widgets/widgets.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InternalPageLayout(
      title: 'Exercise',
      child: EmptyState(
        title: 'Exercise module placeholder',
        description: 'TODO: Add workout sessions, intensity tracking, and routines.',
      ),
    );
  }
}
