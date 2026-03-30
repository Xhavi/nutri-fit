import '../models/entitlement_status.dart';
import '../models/subscription_plan.dart';

abstract class SubscriptionRepository {
  Future<void> initialize();

  Future<SubscriptionPlan?> getMonthlyPlan();

  Future<EntitlementStatus> getEntitlementStatus();

  Stream<EntitlementStatus> watchEntitlementStatus();

  Future<bool> purchaseMonthlyPlan();

  Future<void> restorePurchases();

  Future<void> refreshAiChatQuota();

  Future<void> dispose();
}
