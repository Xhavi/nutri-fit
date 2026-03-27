import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/features/nutrition/data/repositories/mock_nutrition_repository.dart';
import 'package:nutri_fit/features/nutrition/domain/entities/food_item.dart';
import 'package:nutri_fit/features/nutrition/domain/enums/meal_type.dart';
import 'package:nutri_fit/features/nutrition/presentation/controllers/nutrition_controller.dart';

void main() {
  test('agrega comida y actualiza resumen en estado', () async {
    final NutritionController controller = NutritionController(
      repository: MockNutritionRepository(),
    );

    await controller.initialize();
    final int initialEntries = controller.state.entries.length;

    await controller.saveMealEntry(
      existingId: null,
      mealType: MealType.dinner,
      date: controller.state.selectedDate,
      foodItems: const <FoodItem>[
        FoodItem(id: 'test', name: 'Salmón', calories: 280, protein: 26, carbs: 0, fat: 18),
      ],
    );

    expect(controller.state.entries.length, initialEntries + 1);
    expect(controller.state.summary.calories, greaterThan(0));
  });

  test('actualiza agua del día', () async {
    final NutritionController controller = NutritionController(
      repository: MockNutritionRepository(),
    );
    await controller.initialize();

    await controller.setWater(2000);

    expect(controller.state.waterMl, 2000);
    expect(controller.state.summary.waterMl, 2000);
  });
}
