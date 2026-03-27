import '../enums/meal_type.dart';
import 'food_item.dart';

class MealEntry {
  const MealEntry({
    required this.id,
    required this.date,
    required this.mealType,
    required this.foodItems,
    this.notes,
  });

  final String id;
  final DateTime date;
  final MealType mealType;
  final List<FoodItem> foodItems;
  final String? notes;

  double get totalCalories => foodItems.fold<double>(0, (double sum, FoodItem item) => sum + item.calories);
  double get totalProtein => foodItems.fold<double>(0, (double sum, FoodItem item) => sum + item.protein);
  double get totalCarbs => foodItems.fold<double>(0, (double sum, FoodItem item) => sum + item.carbs);
  double get totalFat => foodItems.fold<double>(0, (double sum, FoodItem item) => sum + item.fat);

  MealEntry copyWith({
    String? id,
    DateTime? date,
    MealType? mealType,
    List<FoodItem>? foodItems,
    String? notes,
  }) {
    return MealEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      foodItems: foodItems ?? this.foodItems,
      notes: notes ?? this.notes,
    );
  }
}
