import 'package:flutter/material.dart';

import '../../../../shared/layouts/internal_base_layout.dart';
import '../../../../shared/widgets/empty_state.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InternalBaseLayout(
      title: 'Ejercicio',
      currentIndex: 2,
      child: EmptyState(
        title: 'Módulo de ejercicio',
        description: 'TODO: Integrar rutinas, sesiones y métricas de entrenamiento.',
        icon: Icons.fitness_center_rounded,
      ),
    );
  }
}
