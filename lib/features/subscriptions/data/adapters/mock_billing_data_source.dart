import 'dart:async';

import '../../domain/models/entitlement_status.dart';
import '../../domain/models/subscription_plan.dart';
import 'billing_data_source.dart';

class MockBillingDataSource implements BillingDataSource {
  MockBillingDataSource({bool startPremium = false})
      : _status = EntitlementStatus(
          tier: EntitlementTier.premiumAi,
          isActive: startPremium,
          source: 'mock',
          totalUnits: 100,
          consumedUnits: 20,
        );

  final StreamController<EntitlementStatus> _controller =
      StreamController<EntitlementStatus>.broadcast();
  final StreamController<BillingPurchaseUpdate> _purchaseUpdatesController =
      StreamController<BillingPurchaseUpdate>.broadcast();

  EntitlementStatus _status;

  @override
  Future<void> initialize() async {
    _controller.add(_status);
  }

  @override
  Future<SubscriptionPlan?> getMonthlyPlan() async {
    return const SubscriptionPlan(
      sku: BillingProductIds.aiMonthly499,
      title: 'NutriFit AI Premium',
      description: 'Coaching IA y voz inteligente para tu plan de wellness.',
      billingPeriod: 'P1M',
      priceLabel: r'$4.99/mes',
      autoRenewing: true,
    );
  }

  @override
  Future<EntitlementStatus> getEntitlementStatus() async {
    return _status;
  }

  @override
  Stream<EntitlementStatus> watchEntitlementStatus() {
    return _controller.stream;
  }

  @override
  Stream<BillingPurchaseUpdate> watchPurchaseUpdates() {
    return _purchaseUpdatesController.stream;
  }

  @override
  Future<bool> purchaseMonthlyPlan(SubscriptionPlan plan) async {
    _status = EntitlementStatus(
      tier: EntitlementTier.premiumAi,
      isActive: true,
      source: 'mock',
      totalUnits: 100,
      consumedUnits: _status.consumedUnits,
    );

    _purchaseUpdatesController.add(
      const BillingPurchaseUpdate(
        type: BillingPurchaseUpdateType.purchased,
        productId: BillingProductIds.aiMonthly499,
        purchaseToken: 'mock-token',
        orderId: 'mock-order',
      ),
    );
    _controller.add(_status);
    return true;
  }

  @override
  Future<void> restorePurchases() async {
    _purchaseUpdatesController.add(
      const BillingPurchaseUpdate(
        type: BillingPurchaseUpdateType.restored,
        productId: BillingProductIds.aiMonthly499,
        purchaseToken: 'mock-token-restore',
        orderId: 'mock-order-restore',
      ),
    );
    _controller.add(_status);
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
    await _purchaseUpdatesController.close();
  }
}
