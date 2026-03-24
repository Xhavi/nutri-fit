import 'package:flutter/material.dart';

import '../../../shared/layouts/layouts.dart';
import '../../../shared/widgets/widgets.dart';

class AiCoachScreen extends StatelessWidget {
  const AiCoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InternalPageLayout(
      title: 'AI Coach',
      child: EmptyState(
        title: 'AI Coach placeholder',
        description: 'TODO: Add conversation UI and backend orchestration integration.',
      ),
    );
  }
}
