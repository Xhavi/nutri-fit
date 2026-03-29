import 'package:flutter/material.dart';

import '../../domain/models/entitlement_status.dart';

class QuotaStatusCard extends StatelessWidget {
  const QuotaStatusCard({required this.status, super.key});

  final EntitlementStatus status;

  @override
  Widget build(BuildContext context) {
    final int? total = status.totalUnits;
    final int used = status.consumedUnits;

    if (total == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.insights_rounded),
          title: const Text('Cuota IA'),
          subtitle: const Text('La cuota se habilita cuando la suscripción premium está activa.'),
        ),
      );
    }

    final double progress = total == 0 ? 0 : (used / total).clamp(0, 1).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Uso mensual de IA', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text('Consumido: $used / $total'),
            Text('Restante: ${status.remainingUnits ?? 0}'),
          ],
        ),
      ),
    );
  }
}
