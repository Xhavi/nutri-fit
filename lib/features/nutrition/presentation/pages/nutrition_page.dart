import 'package:flutter/material.dart';

import '../../../../shared/layouts/internal_base_layout.dart';
import '../../../../shared/widgets/empty_state.dart';

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InternalBaseLayout(
      title: 'Nutrición',
      currentIndex: 1,
      child: EmptyState(
        title: 'Módulo de nutrición',
        description: 'TODO: Integrar tracking de comidas, macros y recomendaciones.',
        icon: Icons.restaurant_menu_rounded,
      ),
    );
  }
}
