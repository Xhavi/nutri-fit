import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/subscription_providers.dart';
import '../controllers/subscription_state.dart';
import '../widgets/premium_status_badge.dart';
import '../widgets/quota_status_card.dart';

class PaywallPage extends ConsumerWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SubscriptionState state = ref.watch(subscriptionStateProvider);
    final controller = ref.read(subscriptionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('NutriFit AI Premium')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            PremiumStatusBadge(isPremium: state.hasPremium),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Suscripción mensual IA', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      state.plan == null
                          ? 'Producto no disponible todavía en Play Console para este entorno.'
                          : '${state.plan!.title} · ${state.plan!.priceLabel}',
                    ),
                    const SizedBox(height: 4),
                    const Text('SKU: nutrifit_ai_monthly_499'),
                    const Text('Renovación automática mensual'),
                    const SizedBox(height: 8),
                    Text(
                      'Incluye funcionalidades premium de IA (chat + voz), mientras nutrición, ejercicio y progreso siguen siendo gratis.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            QuotaStatusCard(status: state.status),
            if (state.errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (state.lifecycleMessage != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                state.lifecycleMessage!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: state.isLoading ? null : controller.purchase,
              icon: state.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.workspace_premium_rounded),
              label: const Text('Activar AI Premium'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: state.isLoading ? null : controller.restore,
              child: const Text('Restaurar compras'),
            ),
            const SizedBox(height: 10),
            Text(
              'Las compras se sincronizan con backend para validar token de Google Play antes de activar entitlement definitivo.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
