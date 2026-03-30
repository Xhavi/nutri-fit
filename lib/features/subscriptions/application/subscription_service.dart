import '../domain/models/entitlement_status.dart';
import '../domain/models/subscription_plan.dart';
import '../domain/repositories/subscription_repository.dart';

class SubscriptionService {
  SubscriptionService({required SubscriptionRepository repository})
      : _repository = repository;

  final SubscriptionRepository _repository;

  Future<void> initialize() => _repository.initialize();

  Future<SubscriptionPlan?> loadPlan() => _repository.getMonthlyPlan();

  Future<EntitlementStatus> getStatus() => _repository.getEntitlementStatus();

  Stream<EntitlementStatus> watchStatus() => _repository.watchEntitlementStatus();

  Future<bool> purchaseMonthlyPlan() => _repository.purchaseMonthlyPlan();

  Future<void> restorePurchases() => _repository.restorePurchases();

  Future<void> refreshAiChatQuota() => _repository.refreshAiChatQuota();

  Future<void> dispose() => _repository.dispose();
}
