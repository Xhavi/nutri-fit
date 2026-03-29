import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../features/exercise/presentation/controllers/exercise_providers.dart';
import '../../../../shared/layouts/internal_base_layout.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../subscriptions/presentation/controllers/subscription_providers.dart';
import '../../../subscriptions/presentation/widgets/premium_status_badge.dart';
import '../../../subscriptions/presentation/widgets/quota_status_card.dart';
import 'edit_health_profile_page.dart';
import 'goals_review_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseState = ref.watch(exerciseStateProvider);
    final subscriptionState = ref.watch(subscriptionStateProvider);

    return InternalBaseLayout(
      title: 'Perfil',
      currentIndex: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Personalización de salud', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            'Configura perfil, metas y preferencias para construir objetivos de wellness base.',
          ),
          const SizedBox(height: 16),
          PremiumStatusBadge(isPremium: subscriptionState.hasPremium),
          const SizedBox(height: 8),
          QuotaStatusCard(status: subscriptionState.status),
          const SizedBox(height: 12),
          if (!subscriptionState.hasPremium)
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutePaths.paywall),
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text('Desbloquear AI Premium'),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Actividad física de hoy', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text('Entrenamientos: ${exerciseState.dailySummary.workoutCount}'),
                  Text('Minutos acumulados: ${exerciseState.dailySummary.totalMinutes}'),
                  Text(
                    'Calorías estimadas: ${exerciseState.dailySummary.estimatedCalories.toStringAsFixed(0)} kcal',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Editar perfil de salud',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const EditHealthProfilePage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Revisar objetivos y cálculo',
            isSecondary: true,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const GoalsReviewPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Nota: NutriFit ofrece guía de bienestar general. No realiza diagnóstico médico.',
          ),
        ],
      ),
    );
  }
}
