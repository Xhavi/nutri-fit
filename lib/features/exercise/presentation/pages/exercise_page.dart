import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/layouts/internal_base_layout.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/workout.dart';
import '../controllers/exercise_providers.dart';
import '../controllers/exercise_state.dart';
import 'add_workout_page.dart';
import 'exercise_history_page.dart';
import 'workout_detail_page.dart';

class ExercisePage extends ConsumerWidget {
  const ExercisePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ExerciseState state = ref.watch(exerciseStateProvider);
    final controller = ref.read(exerciseControllerProvider);

    return InternalBaseLayout(
      title: 'Ejercicio',
      currentIndex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Entrenamientos de hoy', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(DateFormat('EEEE, d MMMM', 'es').format(state.selectedDate)),
          const SizedBox(height: 12),
          _DailySummaryCard(state: state),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton(
                  label: 'Agregar entrenamiento',
                  leading: const Icon(Icons.add),
                  onPressed: () async {
                    final AddWorkoutResult? result = await Navigator.of(context).push<AddWorkoutResult>(
                      MaterialPageRoute<AddWorkoutResult>(
                        builder: (_) => const AddWorkoutPage(),
                      ),
                    );
                    if (result == null) {
                      return;
                    }
                    await controller.addWorkout(
                      title: result.title,
                      date: state.selectedDate,
                      category: result.category,
                      durationMinutes: result.durationMinutes,
                      intensity: result.intensity,
                      notes: result.notes,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'Ver historial',
                  isSecondary: true,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ExerciseHistoryPage(
                          history: state.history,
                          onOpenDetail: (Workout workout) {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => WorkoutDetailPage(
                                  workout: workout,
                                  weightKg: state.estimatedWeightKg,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _FutureExtensionsHint(),
          const SizedBox(height: 12),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.dailyWorkouts.isEmpty
                    ? const Center(
                        child: Text('Aún no registras entrenamientos para hoy.'),
                      )
                    : ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          final Workout workout = state.dailyWorkouts[index];
                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.fitness_center_rounded)),
                              title: Text(workout.title),
                              subtitle: Text(
                                '${workout.totalDuration.inMinutes} min · '
                                '${workout.estimatedCalories(weightKg: state.estimatedWeightKg).toStringAsFixed(0)} kcal',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => controller.deleteWorkout(workout.id),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => WorkoutDetailPage(
                                      workout: workout,
                                      weightKg: state.estimatedWeightKg,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: state.dailyWorkouts.length,
                      ),
          ),
        ],
      ),
    );
  }
}

class _DailySummaryCard extends StatelessWidget {
  const _DailySummaryCard({required this.state});

  final ExerciseState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Resumen diario', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Chip(label: Text('Entrenamientos: ${state.dailySummary.workoutCount}')),
                Chip(label: Text('Minutos: ${state.dailySummary.totalMinutes}')),
                Chip(label: Text('Kcal estimadas: ${state.dailySummary.estimatedCalories.toStringAsFixed(0)}')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FutureExtensionsHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'Preparado para próximas fases: planes de ejercicio y recomendaciones por objetivo '
          '(sin habilitar lógica completa aún).',
        ),
      ),
    );
  }
}
