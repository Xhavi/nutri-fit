import 'package:uuid/uuid.dart';

import '../../domain/entities/food_item.dart';
import '../../domain/entities/meal_entry.dart';
import '../../domain/enums/meal_type.dart';
import '../../domain/repositories/nutrition_repository.dart';

class MockNutritionRepository implements NutritionRepository {
  MockNutritionRepository() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    _entries = <MealEntry>[
      MealEntry(
        id: _uuid.v4(),
        date: today,
        mealType: MealType.breakfast,
        foodItems: <FoodItem>[
          const FoodItem(
            id: 'food-oats',
            name: 'Avena con leche',
            calories: 240,
            protein: 11,
            carbs: 33,
            fat: 7,
            servingDescription: '1 bowl',
          ),
        ],
      ),
    ];

    _waterByDate[_toDateKey(today)] = 800;
  }

  final Uuid _uuid = const Uuid();
  late List<MealEntry> _entries;
  final Map<String, int> _waterByDate = <String, int>{};

  static const List<FoodItem> _catalog = <FoodItem>[
    FoodItem(id: 'apple', name: 'Manzana', calories: 95, protein: 0.5, carbs: 25, fat: 0.3),
    FoodItem(id: 'rice', name: 'Arroz cocido', calories: 205, protein: 4.3, carbs: 45, fat: 0.4),
    FoodItem(id: 'chicken', name: 'Pechuga de pollo', calories: 165, protein: 31, carbs: 0, fat: 3.6),
    FoodItem(id: 'eggs', name: 'Huevos revueltos', calories: 180, protein: 12, carbs: 1.4, fat: 13),
    FoodItem(id: 'yogurt', name: 'Yogur griego', calories: 130, protein: 12, carbs: 9, fat: 4),
  ];

  @override
  Future<void> addMealEntry(MealEntry entry) async {
    _entries = <MealEntry>[..._entries, entry.copyWith(id: entry.id.isEmpty ? _uuid.v4() : entry.id)];
  }

  @override
  Future<void> deleteMealEntry(String entryId) async {
    _entries = _entries.where((MealEntry entry) => entry.id != entryId).toList();
  }

  @override
  Future<List<MealEntry>> getEntriesForDate(DateTime date) async {
    return _entries.where((MealEntry entry) => _isSameDate(entry.date, date)).toList()
      ..sort((MealEntry a, MealEntry b) => a.mealType.index.compareTo(b.mealType.index));
  }

  @override
  Future<int> getWaterForDate(DateTime date) async {
    return _waterByDate[_toDateKey(date)] ?? 0;
  }

  @override
  Future<List<FoodItem>> searchFoods(String query) async {
    if (query.trim().isEmpty) {
      return _catalog;
    }

    final String normalized = query.toLowerCase().trim();
    return _catalog.where((FoodItem item) => item.name.toLowerCase().contains(normalized)).toList();
  }

  @override
  Future<void> setWaterForDate({required DateTime date, required int waterMl}) async {
    _waterByDate[_toDateKey(date)] = waterMl.clamp(0, 10000);
  }

  @override
  Future<void> updateMealEntry(MealEntry entry) async {
    _entries = _entries
        .map((MealEntry existing) => existing.id == entry.id ? entry : existing)
        .toList();
  }

  String _toDateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
