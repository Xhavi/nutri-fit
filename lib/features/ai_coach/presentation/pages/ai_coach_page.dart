import 'package:flutter/material.dart';

import '../../../../shared/layouts/internal_base_layout.dart';
import '../../../../shared/widgets/empty_state.dart';

class AiCoachPage extends StatelessWidget {
  const AiCoachPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InternalBaseLayout(
      title: 'AI Coach',
      currentIndex: 4,
      child: EmptyState(
        title: 'Coach de bienestar',
        description:
            'TODO: Conectar chat e inferencias para guidance de bienestar no clínico.',
        icon: Icons.smart_toy_rounded,
      ),
    );
  }
}
