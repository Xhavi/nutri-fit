import 'package:flutter/material.dart';

import '../../../shared/layouts/layouts.dart';
import '../../../shared/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InternalPageLayout(
      title: 'Home',
      child: EmptyState(
        title: 'Dashboard coming next',
        description: 'TODO: Add personalized daily summary widgets and quick actions.',
      ),
    );
  }
}
