import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/layouts/internal_base_layout.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/entities/meal_entry.dart';
import '../controllers/nutrition_providers.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/meal_entry_tile.dart';
import '../widgets/future_extensions_hint.dart';
import '../widgets/water_tracker_card.dart';
import 'add_edit_meal_page.dart';

class NutritionPage extends ConsumerWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionState = ref.watch(nutritionStateProvider);
    final controller = ref.read(nutritionControllerProvider);

    return InternalBaseLayout(
      title: 'Nutrición',
      currentIndex: 1,
      child: Column(
        children: <Widget>[
          DailySummaryCard(summary: nutritionState.summary),
          const SizedBox(height: 12),
          WaterTrackerCard(
            waterMl: nutritionState.waterMl,
            onWaterChanged: (int value) => controller.setWater(value),
          ),
          const SizedBox(height: 12),
          const FutureExtensionsHint(),
          const SizedBox(height: 12),
          Expanded(
            child: nutritionState.entries.isEmpty
                ? const EmptyState(
                    title: 'Sin comidas registradas',
                    description: 'Agrega tu primera comida para empezar a trackear macros.',
                    icon: Icons.restaurant_menu_rounded,
                  )
                : ListView.builder(
                    itemCount: nutritionState.entries.length,
                    itemBuilder: (BuildContext context, int index) {
                      final MealEntry entry = nutritionState.entries[index];
                      return MealEntryTile(
                        entry: entry,
                        onEdit: () => _openMealForm(context, nutritionState.selectedDate, entry: entry),
                        onDelete: () => controller.deleteMealEntry(entry.id),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openMealForm(context, nutritionState.selectedDate),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar comida'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMealForm(BuildContext context, DateTime selectedDate, {MealEntry? entry}) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddEditMealPage(selectedDate: selectedDate, entry: entry),
      ),
    );
  }
}
