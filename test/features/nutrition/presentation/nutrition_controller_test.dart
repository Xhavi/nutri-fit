import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/core/utils/date_time_utils.dart';
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
        FoodItem(
          id: 'test',
          name: 'Salmon',
          calories: 280,
          protein: 26,
          carbs: 0,
          fat: 18,
        ),
      ],
    );

    expect(controller.state.entries.length, initialEntries + 1);
    expect(controller.state.summary.calories, greaterThan(0));
  });

  test('actualiza agua del dia', () async {
    final NutritionController controller = NutritionController(
      repository: MockNutritionRepository(),
    );
    await controller.initialize();

    await controller.setWater(2000);

    expect(controller.state.waterMl, 2000);
    expect(controller.state.summary.waterMl, 2000);
  });

  test('limita el agua diaria a 10000 ml', () async {
    final NutritionController controller = NutritionController(
      repository: MockNutritionRepository(),
    );
    await controller.initialize();

    await controller.setWater(12000);

    expect(controller.state.waterMl, 10000);
    expect(controller.state.summary.waterMl, 10000);
  });

  test('cambia de fecha y carga resumen independiente por dia', () async {
    final NutritionController controller = NutritionController(
      repository: MockNutritionRepository(),
    );
    await controller.initialize();

    final DateTime today = controller.state.selectedDate;
    final DateTime nextDay = DateTimeUtils.normalizeDate(
      today.add(const Duration(days: 1)),
    );

    await controller.saveMealEntry(
      existingId: null,
      mealType: MealType.lunch,
      date: nextDay,
      foodItems: const <FoodItem>[
        FoodItem(
          id: 'future-meal',
          name: 'Bowl QA',
          calories: 510,
          protein: 28,
          carbs: 62,
          fat: 18,
        ),
      ],
    );
    await controller.loadForDate(nextDay);

    expect(controller.state.selectedDate, nextDay);
    expect(controller.state.entries, hasLength(1));
    expect(controller.state.summary.calories, 510);

    await controller.loadForDate(today);

    expect(controller.state.selectedDate, today);
    expect(controller.state.entries, isNotEmpty);
    expect(controller.state.summary.calories, isNot(510));
  });
}
