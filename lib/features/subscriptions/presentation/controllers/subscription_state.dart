import '../../domain/models/entitlement_status.dart';
import '../../domain/models/subscription_plan.dart';

class SubscriptionState {
  const SubscriptionState({
    this.plan,
    this.status = const EntitlementStatus(
      tier: EntitlementTier.free,
      isActive: false,
      source: 'unknown',
    ),
    this.isLoading = false,
    this.errorMessage,
  });

  final SubscriptionPlan? plan;
  final EntitlementStatus status;
  final bool isLoading;
  final String? errorMessage;

  bool get hasPremium => status.isActive && status.tier == EntitlementTier.premiumAi;

  String? get lifecycleMessage {
    if (status.source.contains('pending_verification')) {
      return 'Procesando compra y validando con servidor...';
    }
    if (status.source.contains(':canceled') || status.source.contains('play_billing_canceled')) {
      return 'Tu suscripción está cancelada; mantienes premium hasta que termine el periodo activo.';
    }
    if (status.source.contains(':expired')) {
      return 'Tu suscripción expiró. Puedes reactivarla desde Google Play.';
    }
    if (status.source.contains('play_billing_error') || status.source.contains('backend_verification_failed')) {
      return 'No pudimos validar la compra todavía. Intenta restaurar o reintentar en unos minutos.';
    }
    return null;
  }

  SubscriptionState copyWith({
    SubscriptionPlan? plan,
    EntitlementStatus? status,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SubscriptionState(
      plan: plan ?? this.plan,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
