import 'package:flutter/material.dart';

import '../../domain/entities/meal_entry.dart';
import 'macro_chip.dart';

class MealEntryTile extends StatelessWidget {
  const MealEntryTile({
    required this.entry,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final MealEntry entry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  String _f(double value) => value.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    entry.mealType.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_rounded)),
                IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded)),
              ],
            ),
            const SizedBox(height: 6),
            Text(entry.foodItems.map((item) => item.name).join(', ')),
            if ((entry.notes ?? '').isNotEmpty) ...<Widget>[
              const SizedBox(height: 6),
              Text(entry.notes!),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                MacroChip(label: 'kcal', value: _f(entry.totalCalories), color: Colors.green),
                MacroChip(label: 'P', value: '${_f(entry.totalProtein)} g', color: Colors.blue),
                MacroChip(label: 'C', value: '${_f(entry.totalCarbs)} g', color: Colors.orange),
                MacroChip(label: 'G', value: '${_f(entry.totalFat)} g', color: Colors.pink),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
