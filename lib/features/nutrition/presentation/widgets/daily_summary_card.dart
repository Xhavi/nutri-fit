import 'package:flutter/material.dart';

import '../../domain/entities/daily_nutrition_summary.dart';
import 'macro_chip.dart';

class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({required this.summary, super.key});

  final DailyNutritionSummary summary;

  String _format(double value) => value.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Resumen del día', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${_format(summary.calories)} kcal · ${summary.entriesCount} comidas'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                MacroChip(label: 'Proteínas', value: '${_format(summary.protein)} g', color: Colors.blue),
                MacroChip(label: 'Carbs', value: '${_format(summary.carbs)} g', color: Colors.orange),
                MacroChip(label: 'Grasas', value: '${_format(summary.fat)} g', color: Colors.pink),
                MacroChip(label: 'Agua', value: '${summary.waterMl} ml', color: Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
