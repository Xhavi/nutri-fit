import 'package:flutter/material.dart';

import '../../domain/entities/workout.dart';

class WorkoutDetailPage extends StatelessWidget {
  const WorkoutDetailPage({
    required this.workout,
    required this.weightKg,
    super.key,
  });

  final Workout workout;
  final double weightKg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de entrenamiento')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text(workout.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Duración total: ${workout.totalDuration.inMinutes} min'),
            Text('Calorías estimadas: ${workout.estimatedCalories(weightKg: weightKg).toStringAsFixed(0)} kcal'),
            if ((workout.notes ?? '').isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text('Notas: ${workout.notes}'),
            ],
            const SizedBox(height: 16),
            Text('Ejercicios', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...workout.exercises.map(
              (entry) => Card(
                child: ListTile(
                  title: Text(entry.name),
                  subtitle: Text('${entry.category.label} · ${entry.intensity.label}'),
                  trailing: Text('${entry.duration.inMinutes} min'),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('Actividad complementaria', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (workout.activities.isEmpty)
              const Text('Sin actividad adicional registrada.')
            else
              ...workout.activities.map(
                (entry) => Card(
                  child: ListTile(
                    title: Text(entry.name),
                    subtitle: Text(entry.intensity.label),
                    trailing: Text('${entry.duration.inMinutes} min'),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'NutriFit entrega guía de bienestar. Este módulo no emite diagnósticos '
              'ni tratamientos médicos.',
            ),
          ],
        ),
      ),
    );
  }
}
