/// Contratos preparados para futuras integraciones de recetas y planificación.
///
/// No se implementan en este módulo inicial, pero definen la base para una
/// integración futura con APIs o servicios propios de meal planning.
abstract class RecipeCatalogRepository {
  Future<void> getRecommendedRecipes();
}

abstract class MealPlanRepository {
  Future<void> getMealPlanForWeek(DateTime weekStart);
}

abstract class GroceryListRepository {
  Future<void> generateGroceryListFromPlan(String mealPlanId);
}
