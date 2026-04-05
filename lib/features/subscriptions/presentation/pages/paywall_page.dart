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
    final bool canPurchase =
        !state.isLoading && !state.hasPremium && state.plan != null;
    final String productLabel = state.plan == null
        ? 'Producto no disponible todavia en Play Console para este entorno.'
        : '${state.plan!.title} · ${state.plan!.priceLabel}';
    final String skuLabel = state.plan == null
        ? 'SKU pendiente de configuracion'
        : 'SKU: ${state.plan!.sku}';
    final String billingLabel = state.plan == null
        ? 'Configura el producto en Play Console para habilitar compras.'
        : (state.plan!.autoRenewing
            ? 'Renovacion automatica ${state.plan!.billingPeriod}'
            : state.plan!.billingPeriod);

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
                    Text(
                      'Suscripcion mensual IA',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(productLabel),
                    const SizedBox(height: 4),
                    Text(skuLabel),
                    Text(billingLabel),
                    const SizedBox(height: 8),
                    Text(
                      'Incluye chat premium y conversacion por voz con cuotas mensuales para ambas funciones.',
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
              onPressed: canPurchase ? controller.purchase : null,
              icon: state.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.workspace_premium_rounded),
              label: Text(
                state.hasPremium ? 'AI Premium activo' : 'Activar AI Premium',
              ),
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
