import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../features/auth/presentation/controllers/session_providers.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/onboarding_profile.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _foodRestrictionsController = TextEditingController();

  String _sex = 'Prefiero no decir';
  String _goal = 'Perder grasa';
  String _activityLevel = 'Moderado';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _foodRestrictionsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final int? age = int.tryParse(_ageController.text.trim());
    final double? weight = double.tryParse(_weightController.text.trim());
    final double? height = double.tryParse(_heightController.text.trim());

    if (_nameController.text.trim().isEmpty || age == null || weight == null || height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa nombre, edad, peso y talla para continuar.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final OnboardingProfile profile = OnboardingProfile(
      name: _nameController.text.trim(),
      age: age,
      sex: _sex,
      weightKg: weight,
      heightCm: height,
      primaryGoal: _goal,
      activityLevel: _activityLevel,
      foodRestrictions: _foodRestrictionsController.text.trim(),
    );

    await ref.read(sessionControllerProvider).completeOnboarding(profile);
    if (mounted) {
      context.go(AppRoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Onboarding inicial',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SectionHeader(
              title: 'Configura tu experiencia',
              subtitle: 'Responde estas preguntas para personalizar tu plan.',
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Nombre',
              prefixIcon: Icons.person_outline,
              controller: _nameController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Edad',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.cake_outlined,
              controller: _ageController,
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: 'Sexo',
              value: _sex,
              values: const <String>['Femenino', 'Masculino', 'No binario', 'Prefiero no decir'],
              onChanged: (String value) => setState(() => _sex = value),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Peso (kg)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.monitor_weight_outlined,
              controller: _weightController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Talla (cm)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.height,
              controller: _heightController,
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: 'Objetivo principal',
              value: _goal,
              values: const <String>[
                'Perder grasa',
                'Ganar masa muscular',
                'Mejorar energía diaria',
                'Mantener peso',
              ],
              onChanged: (String value) => setState(() => _goal = value),
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: 'Nivel de actividad',
              value: _activityLevel,
              values: const <String>['Bajo', 'Moderado', 'Alto', 'Muy alto'],
              onChanged: (String value) => setState(() => _activityLevel = value),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Restricciones alimentarias',
              hintText: 'Ej: vegetariano, sin lactosa, alergia a nueces',
              prefixIcon: Icons.restaurant_menu,
              controller: _foodRestrictionsController,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: _isSaving ? 'Guardando...' : 'Finalizar onboarding',
              onPressed: _isSaving ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: values
              .map((String item) => DropdownMenuItem<String>(value: item, child: Text(item)))
              .toList(),
          onChanged: (String? selected) {
            if (selected != null) {
              onChanged(selected);
            }
          },
        ),
      ),
    );
  }
}
