import 'package:flutter/material.dart';

import '../../../../shared/layouts/internal_base_layout.dart';
import '../../../../shared/widgets/empty_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InternalBaseLayout(
      title: 'Inicio',
      currentIndex: 0,
      child: EmptyState(
        title: 'Dashboard en construcción',
        description: 'TODO: Conectar cards de resumen, metas y actividad diaria.',
        icon: Icons.home_work_rounded,
      ),
    );
  }
}
