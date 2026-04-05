import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/food_item.dart';
import '../../domain/entities/meal_entry.dart';
import '../../domain/enums/meal_type.dart';
import '../controllers/nutrition_providers.dart';
import '../../../../shared/widgets/app_text_field.dart';

class AddEditMealPage extends ConsumerStatefulWidget {
  const AddEditMealPage({
    required this.selectedDate,
    this.entry,
    super.key,
  });

  final DateTime selectedDate;
  final MealEntry? entry;

  @override
  ConsumerState<AddEditMealPage> createState() => _AddEditMealPageState();
}

class _AddEditMealPageState extends ConsumerState<AddEditMealPage> {
  late MealType _mealType;
  late TextEditingController _foodController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final MealEntry? entry = widget.entry;
    final FoodItem? firstFood =
        entry?.foodItems.isNotEmpty == true ? entry!.foodItems.first : null;
    _mealType = entry?.mealType ?? MealType.breakfast;
    _foodController = TextEditingController(text: firstFood?.name ?? '');
    _caloriesController = TextEditingController(
        text: firstFood?.calories.toStringAsFixed(0) ?? '');
    _proteinController = TextEditingController(
        text: firstFood?.protein.toStringAsFixed(0) ?? '');
    _carbsController =
        TextEditingController(text: firstFood?.carbs.toStringAsFixed(0) ?? '');
    _fatController =
        TextEditingController(text: firstFood?.fat.toStringAsFixed(0) ?? '');
    _notesController = TextEditingController(text: entry?.notes ?? '');
  }

  @override
  void dispose() {
    _foodController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String foodName = _foodController.text.trim();
    if (foodName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Ingresa al menos un alimento para guardar la comida.')),
      );
      return;
    }

    final double? calories = _parseOptionalMetric(_caloriesController);
    final double? protein = _parseOptionalMetric(_proteinController);
    final double? carbs = _parseOptionalMetric(_carbsController);
    final double? fat = _parseOptionalMetric(_fatController);

    if (calories == null || protein == null || carbs == null || fat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Ingresa valores numericos validos para calorias y macros.'),
        ),
      );
      return;
    }

    if (calories < 0 || protein < 0 || carbs < 0 || fat < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las calorias y macros no pueden ser negativas.'),
        ),
      );
      return;
    }

    final FoodItem food = FoodItem(
      id: (widget.entry != null && widget.entry!.foodItems.isNotEmpty)
          ? widget.entry!.foodItems.first.id
          : foodName.toLowerCase().replaceAll(' ', '-'),
      name: foodName,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );

    await ref.read(nutritionControllerProvider).saveMealEntry(
          existingId: widget.entry?.id,
          mealType: _mealType,
          date: widget.selectedDate,
          foodItems: <FoodItem>[food],
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  double? _parseOptionalMetric(TextEditingController controller) {
    final String raw = controller.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) {
      return 0;
    }

    return double.tryParse(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.entry == null ? 'Agregar comida' : 'Editar comida')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            DropdownButtonFormField<MealType>(
              initialValue: _mealType,
              decoration: const InputDecoration(labelText: 'Tipo de comida'),
              items: MealType.values
                  .map(
                    (MealType value) => DropdownMenuItem<MealType>(
                      value: value,
                      child: Text(value.label),
                    ),
                  )
                  .toList(),
              onChanged: (MealType? value) {
                if (value != null) {
                  setState(() => _mealType = value);
                }
              },
            ),
            const SizedBox(height: 12),
            AppTextField(label: 'Alimento', controller: _foodController),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppTextField(
                    label: 'kcal',
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTextField(
                    label: 'Proteínas (g)',
                    controller: _proteinController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppTextField(
                    label: 'Carbs (g)',
                    controller: _carbsController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTextField(
                    label: 'Grasas (g)',
                    controller: _fatController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppTextField(
                label: 'Notas (opcional)',
                controller: _notesController,
                maxLines: 2),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }
}
