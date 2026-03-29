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
