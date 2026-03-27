import 'meal_entry.dart';

class DailyNutritionSummary {
  const DailyNutritionSummary({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.waterMl,
    required this.entriesCount,
  });

  final DateTime date;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final int waterMl;
  final int entriesCount;

  factory DailyNutritionSummary.fromEntries({
    required DateTime date,
    required List<MealEntry> entries,
    required int waterMl,
  }) {
    return DailyNutritionSummary(
      date: date,
      calories: entries.fold<double>(0, (double sum, MealEntry e) => sum + e.totalCalories),
      protein: entries.fold<double>(0, (double sum, MealEntry e) => sum + e.totalProtein),
      carbs: entries.fold<double>(0, (double sum, MealEntry e) => sum + e.totalCarbs),
      fat: entries.fold<double>(0, (double sum, MealEntry e) => sum + e.totalFat),
      waterMl: waterMl,
      entriesCount: entries.length,
    );
  }
}
