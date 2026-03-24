import 'package:flutter/material.dart';

import '../../../shared/layouts/layouts.dart';
import '../../../shared/widgets/widgets.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InternalPageLayout(
      title: 'Nutrition',
      child: EmptyState(
        title: 'Nutrition module placeholder',
        description: 'TODO: Add meal logging, macros, and daily nutrition summaries.',
      ),
    );
  }
}
