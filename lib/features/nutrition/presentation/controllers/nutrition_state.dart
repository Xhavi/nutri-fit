import 'package:nutri_fit/core/utils/date_time_utils.dart';

import '../../domain/entities/daily_nutrition_summary.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/meal_entry.dart';

class NutritionState {
  const NutritionState({
    required this.selectedDate,
    required this.entries,
    required this.waterMl,
    required this.foodSearchResults,
    this.isLoading = false,
  });

  final DateTime selectedDate;
  final List<MealEntry> entries;
  final int waterMl;
  final List<FoodItem> foodSearchResults;
  final bool isLoading;

  DailyNutritionSummary get summary => DailyNutritionSummary.fromEntries(
    date: selectedDate,
    entries: entries,
    waterMl: waterMl,
  );

  NutritionState copyWith({
    DateTime? selectedDate,
    List<MealEntry>? entries,
    int? waterMl,
    List<FoodItem>? foodSearchResults,
    bool? isLoading,
  }) {
    return NutritionState(
      selectedDate: selectedDate ?? this.selectedDate,
      entries: entries ?? this.entries,
      waterMl: waterMl ?? this.waterMl,
      foodSearchResults: foodSearchResults ?? this.foodSearchResults,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory NutritionState.initial() {
    final DateTime now = DateTime.now();
    return NutritionState(
      selectedDate: DateTimeUtils.normalizeDate(now),
      entries: const <MealEntry>[],
      waterMl: 0,
      foodSearchResults: const <FoodItem>[],
    );
  }
}
