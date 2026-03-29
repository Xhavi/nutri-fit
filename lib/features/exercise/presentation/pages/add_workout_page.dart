import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/enums/exercise_category.dart';
import '../../domain/enums/exercise_intensity.dart';

class AddWorkoutPage extends StatefulWidget {
  const AddWorkoutPage({super.key});

  @override
  State<AddWorkoutPage> createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController(text: '30');
  final TextEditingController _notesController = TextEditingController();
  ExerciseCategory _category = ExerciseCategory.strength;
  ExerciseIntensity _intensity = ExerciseIntensity.moderate;

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final String title = _titleController.text.trim();
    final int? duration = int.tryParse(_durationController.text.trim());

    if (title.isEmpty || duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa nombre y duración válida.')),
      );
      return;
    }

    Navigator.of(context).pop<AddWorkoutResult>(
      AddWorkoutResult(
        title: title,
        durationMinutes: duration,
        category: _category,
        intensity: _intensity,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar entrenamiento')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Registro rápido', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Nombre entrenamiento',
                  controller: _titleController,
                  hintText: 'Ej: Cardio intervalado',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Duración (minutos)',
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ExerciseCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: ExerciseCategory.values
                      .map(
                        (ExerciseCategory value) => DropdownMenuItem<ExerciseCategory>(
                          value: value,
                          child: Text(value.label),
                        ),
                      )
                      .toList(),
                  onChanged: (ExerciseCategory? value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ExerciseIntensity>(
                  initialValue: _intensity,
                  decoration: const InputDecoration(labelText: 'Intensidad'),
                  items: ExerciseIntensity.values
                      .map(
                        (ExerciseIntensity value) => DropdownMenuItem<ExerciseIntensity>(
                          value: value,
                          child: Text(value.label),
                        ),
                      )
                      .toList(),
                  onChanged: (ExerciseIntensity? value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _intensity = value);
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Notas (opcional)',
                  controller: _notesController,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                AppButton(label: 'Guardar entrenamiento', onPressed: _save),
                const SizedBox(height: 10),
                const Text(
                  'Nota: Las calorías se estiman con una fórmula simple de MET. '
                  'Esto es guía de bienestar general, no consejo médico.',
                ),
              ],
            ),
        ),
      ),
    );
  }
}

class AddWorkoutResult {
  const AddWorkoutResult({
    required this.title,
    required this.durationMinutes,
    required this.category,
    required this.intensity,
    this.notes,
  });

  final String title;
  final int durationMinutes;
  final ExerciseCategory category;
  final ExerciseIntensity intensity;
  final String? notes;
}
