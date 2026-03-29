import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/layouts/internal_base_layout.dart';
import '../../../auth/presentation/controllers/session_providers.dart';
import '../../../subscriptions/presentation/controllers/subscription_providers.dart';
import '../../../subscriptions/presentation/widgets/premium_status_badge.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionStateProvider);

    return InternalBaseLayout(
      title: 'Ajustes',
      currentIndex: 6,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Cuenta',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                PremiumStatusBadge(isPremium: subscriptionState.hasPremium),
                const SizedBox(height: 10),
                Text(
                  subscriptionState.hasPremium
                      ? 'Tu acceso premium IA está activo.'
                      : 'Las funciones IA premium están bloqueadas hasta activar suscripción.',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.push(AppRoutePaths.paywall),
                  icon: const Icon(Icons.workspace_premium_rounded),
                  label: const Text('Gestionar AI Premium'),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () async {
                    await ref.read(sessionControllerProvider).signOut();
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
