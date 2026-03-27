import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/layouts/internal_base_layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const _DashboardSummary summary = _DashboardSummary(
      userName: 'Sofía',
      objectiveLabel: 'Déficit moderado para recomposición corporal',
      objectiveProgress: 0.68,
      consumedCalories: 1680,
      caloriesTarget: 2100,
      proteinGrams: 122,
      carbsGrams: 165,
      fatGrams: 58,
      waterMl: 1750,
      waterTargetMl: 2500,
      activeMinutes: 42,
      activeMinutesTarget: 60,
      workoutsCompleted: 1,
      workoutsTarget: 2,
      steps: 8314,
      stepsTarget: 10000,
    );

    return InternalBaseLayout(
      title: 'Inicio',
      currentIndex: 0,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _GreetingCard(summary: summary),
            const SizedBox(height: 16),
            _ObjectiveCard(summary: summary),
            const SizedBox(height: 16),
            _NutritionSummaryCard(summary: summary),
            const SizedBox(height: 16),
            _WaterSummaryCard(summary: summary),
            const SizedBox(height: 16),
            _ActivitySummaryCard(summary: summary),
            const SizedBox(height: 20),
            Text('Accesos rápidos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                _QuickAccessChip(
                  label: 'Nutrición',
                  icon: Icons.restaurant_menu_rounded,
                  onTap: () => context.go(AppRoutePaths.nutrition),
                ),
                _QuickAccessChip(
                  label: 'Ejercicio',
                  icon: Icons.fitness_center_rounded,
                  onTap: () => context.go(AppRoutePaths.exercise),
                ),
                _QuickAccessChip(
                  label: 'Progreso',
                  icon: Icons.query_stats_rounded,
                  onTap: () => context.go(AppRoutePaths.progress),
                ),
                _QuickAccessChip(
                  label: 'AI Coach',
                  icon: Icons.smart_toy_rounded,
                  onTap: () => context.go(AppRoutePaths.aiCoach),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.summary});

  final _DashboardSummary summary;

  String _buildGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buenos días';
    }
    if (hour < 19) {
      return 'Buenas tardes';
    }
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(child: Icon(Icons.waving_hand_rounded)),
        title: Text('${_buildGreeting()}, ${summary.userName}'),
        subtitle: const Text('Así va tu día: foco, constancia y decisiones saludables.'),
      ),
    );
  }
}

class _ObjectiveCard extends StatelessWidget {
  const _ObjectiveCard({required this.summary});

  final _DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final int percent = (summary.objectiveProgress * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Objetivo actual', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(summary.objectiveLabel),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: summary.objectiveProgress),
            const SizedBox(height: 8),
            Text('$percent% de cumplimiento semanal'),
          ],
        ),
      ),
    );
  }
}

class _NutritionSummaryCard extends StatelessWidget {
  const _NutritionSummaryCard({required this.summary});

  final _DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final int caloriesLeft = summary.caloriesTarget - summary.consumedCalories;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Calorías y macros', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('${summary.consumedCalories} / ${summary.caloriesTarget} kcal'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: summary.consumedCalories / summary.caloriesTarget),
            const SizedBox(height: 8),
            Text(
              caloriesLeft >= 0
                  ? 'Te quedan $caloriesLeft kcal para hoy.'
                  : 'Vas ${caloriesLeft.abs()} kcal por encima de la meta.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _MacroTag(label: 'Proteínas', value: '${summary.proteinGrams} g'),
                _MacroTag(label: 'Carbohidratos', value: '${summary.carbsGrams} g'),
                _MacroTag(label: 'Grasas', value: '${summary.fatGrams} g'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterSummaryCard extends StatelessWidget {
  const _WaterSummaryCard({required this.summary});

  final _DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final double progress = summary.waterMl / summary.waterTargetMl;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Agua', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('${summary.waterMl} / ${summary.waterTargetMl} ml'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress.clamp(0, 1)),
          ],
        ),
      ),
    );
  }
}

class _ActivitySummaryCard extends StatelessWidget {
  const _ActivitySummaryCard({required this.summary});

  final _DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Actividad y ejercicio', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _MetricRow(
              label: 'Minutos activos',
              value: '${summary.activeMinutes}/${summary.activeMinutesTarget} min',
            ),
            _MetricRow(
              label: 'Entrenamientos',
              value: '${summary.workoutsCompleted}/${summary.workoutsTarget}',
            ),
            _MetricRow(label: 'Pasos', value: '${summary.steps}/${summary.stepsTarget}'),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _QuickAccessChip extends StatelessWidget {
  const _QuickAccessChip({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _MacroTag extends StatelessWidget {
  const _MacroTag({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}

class _DashboardSummary {
  const _DashboardSummary({
    required this.userName,
    required this.objectiveLabel,
    required this.objectiveProgress,
    required this.consumedCalories,
    required this.caloriesTarget,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.waterMl,
    required this.waterTargetMl,
    required this.activeMinutes,
    required this.activeMinutesTarget,
    required this.workoutsCompleted,
    required this.workoutsTarget,
    required this.steps,
    required this.stepsTarget,
  });

  final String userName;
  final String objectiveLabel;
  final double objectiveProgress;
  final int consumedCalories;
  final int caloriesTarget;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final int waterMl;
  final int waterTargetMl;
  final int activeMinutes;
  final int activeMinutesTarget;
  final int workoutsCompleted;
  final int workoutsTarget;
  final int steps;
  final int stepsTarget;
}
