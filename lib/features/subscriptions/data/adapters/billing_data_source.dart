import 'package:in_app_purchase/in_app_purchase.dart';

import '../../domain/models/entitlement_status.dart';
import '../../domain/models/subscription_plan.dart';

abstract class BillingDataSource {
  Future<void> initialize();

  Future<SubscriptionPlan?> getMonthlyPlan();

  Future<EntitlementStatus> getEntitlementStatus();

  Stream<EntitlementStatus> watchEntitlementStatus();

  Future<bool> purchaseMonthlyPlan(SubscriptionPlan plan);

  Future<void> restorePurchases();

  Future<void> dispose();
}

class BillingProductIds {
  BillingProductIds._();

  static const String aiMonthly499 = 'nutrifit_ai_monthly_499';
}

class BillingPurchaseUtils {
  BillingPurchaseUtils._();

  static bool isPurchaseActive(PurchaseDetails purchase) {
    if (purchase.productID != BillingProductIds.aiMonthly499) {
      return false;
    }

    return purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored;
  }
}
