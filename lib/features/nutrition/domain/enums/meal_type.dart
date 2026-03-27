enum MealType {
  breakfast('Desayuno'),
  snackMorning('Snack'),
  lunch('Almuerzo'),
  snackAfternoon('Merienda'),
  dinner('Cena');

  const MealType(this.label);

  final String label;
}
