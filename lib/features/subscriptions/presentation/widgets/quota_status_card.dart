import 'package:flutter/material.dart';

import '../../domain/models/entitlement_status.dart';

class QuotaStatusCard extends StatelessWidget {
  const QuotaStatusCard({required this.status, super.key});

  final EntitlementStatus status;

  @override
  Widget build(BuildContext context) {
    if (!status.isActive || status.tier != EntitlementTier.premiumAi) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.insights_rounded),
          title: const Text('Cuota IA'),
          subtitle: const Text('La cuota se habilita cuando la suscripción premium está activa.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Uso mensual de IA', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            _FeatureQuotaRow(
              title: 'AI Chat',
              quota: status.aiChat,
            ),
            const SizedBox(height: 10),
            _FeatureQuotaRow(
              title: 'AI Voice (V1 desactivado)',
              quota: status.aiVoice,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureQuotaRow extends StatelessWidget {
  const _FeatureQuotaRow({required this.title, required this.quota});

  final String title;
  final FeatureQuotaStatus quota;

  @override
  Widget build(BuildContext context) {
    final int? total = quota.totalUnits;
    final int used = quota.consumedUnits;

    if (total == null) {
      return Text('$title: cuota no disponible en este plan.');
    }

    final double progress = total == 0 ? 0 : (used / total).clamp(0, 1).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 6),
        Text('Consumido: $used / $total'),
        Text('Restante: ${quota.remainingUnits ?? 0}'),
      ],
    );
  }
}
