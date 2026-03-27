import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/food_item.dart';
import '../../domain/entities/meal_entry.dart';
import '../../domain/enums/meal_type.dart';
import '../../domain/repositories/nutrition_repository.dart';
import 'nutrition_state.dart';

class NutritionController extends ChangeNotifier {
  NutritionController({required NutritionRepository repository}) : _repository = repository;

  final NutritionRepository _repository;
  final Uuid _uuid = const Uuid();

  NutritionState _state = NutritionState.initial();
  NutritionState get state => _state;

  Future<void> initialize() async {
    await loadForDate(_state.selectedDate);
  }

  Future<void> loadForDate(DateTime date) async {
    final DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    _state = _state.copyWith(isLoading: true, selectedDate: normalizedDate);
    notifyListeners();

    final List<MealEntry> entries = await _repository.getEntriesForDate(normalizedDate);
    final int waterMl = await _repository.getWaterForDate(normalizedDate);

    _state = _state.copyWith(
      entries: entries,
      waterMl: waterMl,
      isLoading: false,
    );
    notifyListeners();
  }

  Future<void> saveMealEntry({
    required String? existingId,
    required MealType mealType,
    required DateTime date,
    required List<FoodItem> foodItems,
    String? notes,
  }) async {
    final MealEntry entry = MealEntry(
      id: existingId ?? _uuid.v4(),
      date: DateTime(date.year, date.month, date.day),
      mealType: mealType,
      foodItems: foodItems,
      notes: notes,
    );

    if (existingId == null) {
      await _repository.addMealEntry(entry);
    } else {
      await _repository.updateMealEntry(entry);
    }

    await loadForDate(_state.selectedDate);
  }

  Future<void> deleteMealEntry(String entryId) async {
    await _repository.deleteMealEntry(entryId);
    await loadForDate(_state.selectedDate);
  }

  Future<void> setWater(int waterMl) async {
    await _repository.setWaterForDate(date: _state.selectedDate, waterMl: waterMl);
    _state = _state.copyWith(waterMl: waterMl.clamp(0, 10000));
    notifyListeners();
  }

  Future<void> searchFoods(String query) async {
    final List<FoodItem> results = await _repository.searchFoods(query);
    _state = _state.copyWith(foodSearchResults: results);
    notifyListeners();
  }
}
