import 'package:flutter/material.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/health_profile_repository.dart';
import '../../domain/models/health_profile_models.dart';

class EditHealthProfilePage extends StatefulWidget {
  const EditHealthProfilePage({super.key});

  @override
  State<EditHealthProfilePage> createState() => _EditHealthProfilePageState();
}

class _EditHealthProfilePageState extends State<EditHealthProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();

  late final HealthProfileRepository _repository;

  BiologicalSex _sex = BiologicalSex.other;
  ActivityLevel _activityLevel = ActivityLevel.sedentary;
  PrimaryWellnessGoal _goal = PrimaryWellnessGoal.maintainWeight;
  DietaryPreference _dietaryPreference = DietaryPreference.omnivore;
  final Set<DietaryRestriction> _restrictions = <DietaryRestriction>{};

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repository = HealthProfileRepository(localStorage: LocalStorageService());
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final WellnessProfile? profile = await _repository.loadProfile();
    if (profile != null) {
      _nameController.text = profile.userProfile.name;
      _ageController.text = profile.userProfile.age.toString();
      _heightController.text = profile.userProfile.heightCm.toStringAsFixed(0);
      _weightController.text = profile.userProfile.weightKg.toStringAsFixed(1);
      _targetWeightController.text = profile.goals.targetWeightKg?.toStringAsFixed(1) ?? '';
      _sex = profile.userProfile.sex;
      _activityLevel = profile.userProfile.activityLevel;
      _goal = profile.goals.primaryGoal;
      _dietaryPreference = profile.nutritionPreferences.dietaryPreference;
      _restrictions
        ..clear()
        ..addAll(profile.nutritionPreferences.restrictions);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final WellnessProfile profile = WellnessProfile(
      userProfile: UserHealthProfile(
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text) ?? 0,
        sex: _sex,
        heightCm: double.tryParse(_heightController.text) ?? 0,
        weightKg: double.tryParse(_weightController.text) ?? 0,
        activityLevel: _activityLevel,
      ),
      goals: HealthGoals(
        primaryGoal: _goal,
        targetWeightKg: double.tryParse(_targetWeightController.text),
      ),
      nutritionPreferences: NutritionPreferences(
        dietaryPreference: _dietaryPreference,
        restrictions: _restrictions.toList(),
      ),
    );

    await _repository.saveProfile(profile);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil y objetivos guardados.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil de salud')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            AppTextField(label: 'Nombre', controller: _nameController),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Edad',
              controller: _ageController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _enumDropdown<BiologicalSex>(
              label: 'Sexo biológico',
              value: _sex,
              values: BiologicalSex.values,
              itemLabel: (BiologicalSex value) => value.name,
              onChanged: (BiologicalSex value) => setState(() => _sex = value),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Altura (cm)',
              controller: _heightController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Peso (kg)',
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            _enumDropdown<ActivityLevel>(
              label: 'Nivel de actividad',
              value: _activityLevel,
              values: ActivityLevel.values,
              itemLabel: (ActivityLevel value) => value.label,
              onChanged: (ActivityLevel value) => setState(() => _activityLevel = value),
            ),
            const SizedBox(height: 12),
            _enumDropdown<PrimaryWellnessGoal>(
              label: 'Objetivo principal',
              value: _goal,
              values: PrimaryWellnessGoal.values,
              itemLabel: (PrimaryWellnessGoal value) => value.label,
              onChanged: (PrimaryWellnessGoal value) => setState(() => _goal = value),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Peso objetivo (kg, opcional)',
              controller: _targetWeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            _enumDropdown<DietaryPreference>(
              label: 'Preferencia alimentaria',
              value: _dietaryPreference,
              values: DietaryPreference.values,
              itemLabel: (DietaryPreference value) => value.name,
              onChanged: (DietaryPreference value) =>
                  setState(() => _dietaryPreference = value),
            ),
            const SizedBox(height: 12),
            Text('Restricciones', style: Theme.of(context).textTheme.titleMedium),
            ...DietaryRestriction.values.map((DietaryRestriction restriction) {
              return CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(restriction.name),
                value: _restrictions.contains(restriction),
                onChanged: (bool? checked) {
                  setState(() {
                    if (checked ?? false) {
                      _restrictions.add(restriction);
                    } else {
                      _restrictions.remove(restriction);
                    }
                  });
                },
              );
            }),
            const SizedBox(height: 20),
            const Text(
              'Aviso: esta configuración es para bienestar general. No reemplaza evaluación médica.',
            ),
            const SizedBox(height: 20),
            AppButton(label: 'Guardar perfil', onPressed: _save),
          ],
        ),
      ),
    );
  }

  Widget _enumDropdown<T extends Enum>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T value) itemLabel,
    required ValueChanged<T> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: values
          .map(
            (T item) => DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item)),
            ),
          )
          .toList(),
      onChanged: (T? newValue) {
        if (newValue == null) {
          return;
        }
        onChanged(newValue);
      },
      decoration: InputDecoration(labelText: label),
    );
  }
}
