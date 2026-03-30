import 'package:in_app_purchase/in_app_purchase.dart';

import '../../domain/models/entitlement_status.dart';
import '../../domain/models/subscription_plan.dart';

enum BillingPurchaseUpdateType {
  pending,
  purchased,
  restored,
  canceled,
  error,
}

class BillingPurchaseUpdate {
  const BillingPurchaseUpdate({
    required this.type,
    required this.productId,
    this.purchaseToken,
    this.orderId,
    this.errorMessage,
    this.purchaseTime,
  });

  final BillingPurchaseUpdateType type;
  final String productId;
  final String? purchaseToken;
  final String? orderId;
  final String? errorMessage;
  final DateTime? purchaseTime;
}

abstract class BillingDataSource {
  Future<void> initialize();

  Future<SubscriptionPlan?> getMonthlyPlan();

  Future<EntitlementStatus> getEntitlementStatus();

  Stream<EntitlementStatus> watchEntitlementStatus();

  Stream<BillingPurchaseUpdate> watchPurchaseUpdates();

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

  static BillingPurchaseUpdateType toUpdateType(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.pending:
        return BillingPurchaseUpdateType.pending;
      case PurchaseStatus.purchased:
        return BillingPurchaseUpdateType.purchased;
      case PurchaseStatus.restored:
        return BillingPurchaseUpdateType.restored;
      case PurchaseStatus.error:
        return BillingPurchaseUpdateType.error;
      case PurchaseStatus.canceled:
        return BillingPurchaseUpdateType.canceled;
    }
  }
}
