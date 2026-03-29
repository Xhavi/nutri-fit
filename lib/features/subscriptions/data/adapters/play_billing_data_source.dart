import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../../domain/models/entitlement_status.dart';
import '../../domain/models/subscription_plan.dart';
import 'billing_data_source.dart';

class PlayBillingDataSource implements BillingDataSource {
  PlayBillingDataSource({InAppPurchase? inAppPurchase})
      : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _inAppPurchase;
  final StreamController<EntitlementStatus> _controller =
      StreamController<EntitlementStatus>.broadcast();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  ProductDetails? _product;
  EntitlementStatus _status = const EntitlementStatus(
    tier: EntitlementTier.free,
    isActive: false,
    source: 'unknown',
  );

  @override
  Future<void> initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      _status = const EntitlementStatus(
        tier: EntitlementTier.free,
        isActive: false,
        source: 'play_billing_unavailable',
      );
      _controller.add(_status);
      return;
    }

    _purchaseSub = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdates,
      onDone: () => _purchaseSub?.cancel(),
      onError: (_) {
        _controller.add(_status);
      },
    );

    await _loadProduct();
    await restorePurchases();
  }

  Future<void> _loadProduct() async {
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(
      <String>{BillingProductIds.aiMonthly499},
    );

    if (response.productDetails.isNotEmpty) {
      _product = response.productDetails.first;
    }
  }

  @override
  Future<SubscriptionPlan?> getMonthlyPlan() async {
    _product ??= (await _inAppPurchase
            .queryProductDetails(<String>{BillingProductIds.aiMonthly499}))
        .productDetails
        .firstOrNull;

    final ProductDetails? product = _product;
    if (product == null) {
      return null;
    }

    return SubscriptionPlan(
      sku: product.id,
      title: product.title,
      description: product.description,
      billingPeriod: 'P1M',
      priceLabel: product.price,
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
  Future<bool> purchaseMonthlyPlan(SubscriptionPlan plan) async {
    _product ??= (await _inAppPurchase
            .queryProductDetails(<String>{BillingProductIds.aiMonthly499}))
        .productDetails
        .firstOrNull;

    final ProductDetails? product = _product;
    if (product == null) {
      return false;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    return _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
    _controller.add(_status);
  }

  void _onPurchaseUpdates(List<PurchaseDetails> purchases) {
    bool hasActive = false;

    for (final PurchaseDetails purchase in purchases) {
      if (BillingPurchaseUtils.isPurchaseActive(purchase)) {
        hasActive = true;
      }

      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
    }

    _status = EntitlementStatus(
      tier: hasActive ? EntitlementTier.premiumAi : EntitlementTier.free,
      isActive: hasActive,
      source: 'play_billing',
      totalUnits: hasActive ? 100 : null,
      consumedUnits: hasActive ? 0 : 0,
    );

    // TODO(backend-verification): Replace local purchase interpretation with
    // server-side verification of Play purchase tokens before granting premium.
    _controller.add(_status);
  }

  @override
  Future<void> dispose() async {
    await _purchaseSub?.cancel();
    await _controller.close();
  }
}
