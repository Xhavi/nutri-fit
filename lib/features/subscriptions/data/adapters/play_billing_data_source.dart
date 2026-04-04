import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../../domain/models/entitlement_status.dart';
import '../../domain/models/subscription_plan.dart';
import 'billing_data_source.dart';

class PlayBillingDataSource implements BillingDataSource {
  PlayBillingDataSource({InAppPurchase? inAppPurchase})
      : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _inAppPurchase;
  final StreamController<EntitlementStatus> _entitlementController =
      StreamController<EntitlementStatus>.broadcast();
  final StreamController<BillingPurchaseUpdate> _purchaseUpdatesController =
      StreamController<BillingPurchaseUpdate>.broadcast();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  ProductDetails? _product;
  EntitlementStatus _status = const EntitlementStatus(
    tier: EntitlementTier.free,
    isActive: false,
    source: 'unknown',
    featureAccess: <PremiumFeature, FeatureEntitlementStatus>{
      PremiumFeature.aiChat: FeatureEntitlementStatus.unavailable(
        PremiumFeature.aiChat,
      ),
      PremiumFeature.aiVoice: FeatureEntitlementStatus.unavailable(
        PremiumFeature.aiVoice,
      ),
    },
  );

  @override
  Future<void> initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      _status = const EntitlementStatus(
        tier: EntitlementTier.free,
        isActive: false,
        source: 'play_billing_unavailable',
        featureAccess: <PremiumFeature, FeatureEntitlementStatus>{
          PremiumFeature.aiChat: FeatureEntitlementStatus.unavailable(
            PremiumFeature.aiChat,
          ),
          PremiumFeature.aiVoice: FeatureEntitlementStatus.unavailable(
            PremiumFeature.aiVoice,
          ),
        },
      );
      _entitlementController.add(_status);
      return;
    }

    _purchaseSub = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdates,
      onDone: () => _purchaseSub?.cancel(),
      onError: (Object error) {
        _purchaseUpdatesController.add(
          BillingPurchaseUpdate(
            type: BillingPurchaseUpdateType.error,
            productId: BillingProductIds.aiMonthly499,
            errorMessage: error.toString(),
          ),
        );
        _entitlementController.add(_status);
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
    return _entitlementController.stream;
  }

  @override
  Stream<BillingPurchaseUpdate> watchPurchaseUpdates() {
    return _purchaseUpdatesController.stream;
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
    _entitlementController.add(_status);
  }

  void _onPurchaseUpdates(List<PurchaseDetails> purchases) {
    bool hasActive = false;

    for (final PurchaseDetails purchase in purchases) {
      if (purchase.productID != BillingProductIds.aiMonthly499) {
        continue;
      }

      if (BillingPurchaseUtils.isPurchaseActive(purchase)) {
        hasActive = true;
      }

      _purchaseUpdatesController.add(
        BillingPurchaseUpdate(
          type: BillingPurchaseUtils.toUpdateType(purchase.status),
          productId: purchase.productID,
          purchaseToken: purchase.verificationData.serverVerificationData,
          orderId: purchase.purchaseID,
          errorMessage: purchase.error?.message,
          purchaseTime: purchase.transactionDate == null
              ? null
              : DateTime.tryParse(purchase.transactionDate!),
        ),
      );

      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
    }

    _status = EntitlementStatus(
      tier: hasActive ? EntitlementTier.premiumAi : EntitlementTier.free,
      isActive: false,
      source: hasActive
          ? 'play_billing_local_pending_server_validation'
          : 'play_billing_local',
      featureAccess: hasActive
          ? _pendingFeatureAccess()
          : const <PremiumFeature, FeatureEntitlementStatus>{
              PremiumFeature.aiChat: FeatureEntitlementStatus.unavailable(
                PremiumFeature.aiChat,
              ),
              PremiumFeature.aiVoice: FeatureEntitlementStatus.unavailable(
                PremiumFeature.aiVoice,
              ),
            },
    );

    _entitlementController.add(_status);
  }

  @override
  Future<void> dispose() async {
    await _purchaseSub?.cancel();
    await _entitlementController.close();
    await _purchaseUpdatesController.close();
  }
}

Map<PremiumFeature, FeatureEntitlementStatus> _pendingFeatureAccess() {
  return <PremiumFeature, FeatureEntitlementStatus>{
    PremiumFeature.aiChat: const FeatureEntitlementStatus(
      feature: PremiumFeature.aiChat,
      entitled: true,
      allowed: false,
      quota: 0,
      used: 0,
      remaining: 0,
      reason: 'pending_verification',
    ),
    PremiumFeature.aiVoice: const FeatureEntitlementStatus(
      feature: PremiumFeature.aiVoice,
      entitled: true,
      allowed: false,
      quota: 0,
      used: 0,
      remaining: 0,
      reason: 'pending_verification',
    ),
  };
}
