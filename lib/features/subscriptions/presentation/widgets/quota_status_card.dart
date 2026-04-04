import 'package:flutter/material.dart';

import '../../domain/models/entitlement_status.dart';

class QuotaStatusCard extends StatelessWidget {
  const QuotaStatusCard({required this.status, super.key});

  final EntitlementStatus status;

  @override
  Widget build(BuildContext context) {
    final List<FeatureEntitlementStatus> featureStatuses = status.featureAccess.values
        .where((FeatureEntitlementStatus featureStatus) {
          return featureStatus.entitled || featureStatus.hasQuota;
        })
        .toList(growable: false);

    if (featureStatuses.isNotEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Uso mensual de IA', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...featureStatuses.map(
                (FeatureEntitlementStatus featureStatus) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FeatureQuotaRow(featureStatus: featureStatus),
                ),
              ),
            ],
          ),
        ),
      );
    }

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

class _FeatureQuotaRow extends StatelessWidget {
  const _FeatureQuotaRow({required this.featureStatus});

  final FeatureEntitlementStatus featureStatus;

  @override
  Widget build(BuildContext context) {
    final double progress = featureStatus.quota == 0
        ? 0
        : (featureStatus.used / featureStatus.quota).clamp(0, 1).toDouble();

    final String subtitle;
    if (!featureStatus.entitled) {
      subtitle = 'No incluido en el plan actual.';
    } else if (!featureStatus.allowed && featureStatus.reason == 'subscription_not_active') {
      subtitle = 'Disponible cuando la suscripción quede activa.';
    } else if (!featureStatus.allowed && featureStatus.reason == 'monthly_quota_exceeded') {
      subtitle = 'Cuota agotada por este ciclo.';
    } else if (featureStatus.quota == 0) {
      subtitle = 'Validando disponibilidad y cuota...';
    } else {
      subtitle = 'Consumido: ${featureStatus.used} / ${featureStatus.quota}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          featureStatus.feature.label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 6),
        Text(subtitle),
        if (featureStatus.quota > 0)
          Text('Restante: ${featureStatus.remaining}'),
      ],
    );
  }
}
