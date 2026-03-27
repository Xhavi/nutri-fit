import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/workout.dart';

class ExerciseHistoryPage extends StatelessWidget {
  const ExerciseHistoryPage({
    required this.history,
    required this.onOpenDetail,
    super.key,
  });

  final List<Workout> history;
  final ValueChanged<Workout> onOpenDetail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de actividad')),
      body: SafeArea(
        child: history.isEmpty
            ? const Center(child: Text('Todavía no hay entrenamientos registrados.'))
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemBuilder: (BuildContext context, int index) {
                  final Workout workout = history[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.history)),
                    title: Text(workout.title),
                    subtitle: Text(DateFormat('EEE d MMM', 'es').format(workout.date)),
                    trailing: Text('${workout.totalDuration.inMinutes} min'),
                    onTap: () => onOpenDetail(workout),
                  );
                },
                separatorBuilder: (_, __) => const Divider(),
                itemCount: history.length,
              ),
      ),
    );
  }
}
