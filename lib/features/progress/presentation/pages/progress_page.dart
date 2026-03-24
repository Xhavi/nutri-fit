import 'package:flutter/material.dart';

import '../../../../shared/layouts/internal_base_layout.dart';
import '../../../../shared/widgets/empty_state.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InternalBaseLayout(
      title: 'Progreso',
      currentIndex: 3,
      child: EmptyState(
        title: 'Visualización de progreso',
        description: 'TODO: Integrar gráficas, tendencias y comparativas temporales.',
        icon: Icons.query_stats_rounded,
      ),
    );
  }
}
