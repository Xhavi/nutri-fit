import '../entities/food_item.dart';
import '../entities/meal_entry.dart';

abstract class NutritionRepository {
  Future<List<MealEntry>> getEntriesForDate(DateTime date);
  Future<List<FoodItem>> searchFoods(String query);
  Future<void> addMealEntry(MealEntry entry);
  Future<void> updateMealEntry(MealEntry entry);
  Future<void> deleteMealEntry(String entryId);

  Future<int> getWaterForDate(DateTime date);
  Future<void> setWaterForDate({required DateTime date, required int waterMl});
}
