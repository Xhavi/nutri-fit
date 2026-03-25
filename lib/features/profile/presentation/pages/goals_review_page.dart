import 'package:flutter/material.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../data/health_profile_repository.dart';
import '../../domain/models/health_profile_models.dart';
import '../../domain/use_cases/build_wellness_plan_use_case.dart';
import '../../services/wellness_calculation_service.dart';

class GoalsReviewPage extends StatefulWidget {
  const GoalsReviewPage({super.key});

  @override
  State<GoalsReviewPage> createState() => _GoalsReviewPageState();
}

class _GoalsReviewPageState extends State<GoalsReviewPage> {
  late final HealthProfileRepository _repository;
  late final BuildWellnessPlanUseCase _buildPlanUseCase;

  WellnessProfile? _profile;
  WellnessCalculationResult? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repository = HealthProfileRepository(localStorage: LocalStorageService());
    _buildPlanUseCase = BuildWellnessPlanUseCase(service: WellnessCalculationService());
    _load();
  }

  Future<void> _load() async {
    final WellnessProfile? loaded = await _repository.loadProfile();
    if (!mounted) {
      return;
    }

    setState(() {
      _profile = loaded;
      _result = loaded == null ? null : _buildPlanUseCase.execute(loaded);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_profile == null || _result == null) {
      return const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: EmptyState(
              title: 'Sin perfil cargado',
              description: 'Edita tu perfil primero para calcular metas base.',
              icon: Icons.person_search_rounded,
            ),
          ),
        ),
      );
    }

    final WellnessCalculationResult result = _result!;
    final WellnessProfile profile = _profile!;

    return Scaffold(
      appBar: AppBar(title: const Text('Revisión de objetivos')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text('Perfil: ${profile.userProfile.name}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Objetivo principal: ${profile.goals.primaryGoal.label}'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('IMC: ${result.bmi.toStringAsFixed(1)} (${result.bmiLabel})'),
                    Text('Calorías mantenimiento: ${result.maintenanceCalories} kcal'),
                    Text('Calorías objetivo: ${result.targetCalories} kcal'),
                    const SizedBox(height: 8),
                    Text('Macros objetivo (g/día):'),
                    Text('• Proteína: ${result.targetProteinGrams} g'),
                    Text('• Carbohidratos: ${result.targetCarbsGrams} g'),
                    Text('• Grasas: ${result.targetFatGrams} g'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Metas simples', style: Theme.of(context).textTheme.titleMedium),
            ...result.simpleGoalNotes.map((String note) => Text('• $note')),
            const SizedBox(height: 16),
            Text('Advertencias y TODOs', style: Theme.of(context).textTheme.titleMedium),
            ...result.warnings.map((String warning) => Text('• $warning')),
          ],
        ),
      ),
    );
  }
}
