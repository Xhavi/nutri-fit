import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:nutri_fit/features/nutrition/domain/entities/food_item.dart';
import 'package:nutri_fit/features/nutrition/domain/entities/meal_entry.dart';
import 'package:nutri_fit/features/nutrition/domain/enums/meal_type.dart';

void main() {
  test('calcula resumen diario de calorías, macros y agua', () {
    final DateTime date = DateTime(2026, 3, 25);

    final List<MealEntry> entries = <MealEntry>[
      MealEntry(
        id: '1',
        date: date,
        mealType: MealType.breakfast,
        foodItems: const <FoodItem>[
          FoodItem(id: 'a', name: 'Avena', calories: 200, protein: 10, carbs: 30, fat: 6),
        ],
      ),
      MealEntry(
        id: '2',
        date: date,
        mealType: MealType.lunch,
        foodItems: const <FoodItem>[
          FoodItem(id: 'b', name: 'Pollo', calories: 300, protein: 40, carbs: 0, fat: 12),
        ],
      ),
    ];

    final DailyNutritionSummary summary = DailyNutritionSummary.fromEntries(
      date: date,
      entries: entries,
      waterMl: 1500,
    );

    expect(summary.calories, 500);
    expect(summary.protein, 50);
    expect(summary.carbs, 30);
    expect(summary.fat, 18);
    expect(summary.waterMl, 1500);
    expect(summary.entriesCount, 2);
  });
}
