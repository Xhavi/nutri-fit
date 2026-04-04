import 'dart:async';

import '../../domain/models/entitlement_status.dart';
import '../../domain/models/subscription_plan.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../adapters/billing_data_source.dart';
import '../adapters/subscription_backend_data_source.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({
    required BillingDataSource billingDataSource,
    required SubscriptionBackendDataSource backendDataSource,
  })  : _billingDataSource = billingDataSource,
        _backendDataSource = backendDataSource;

  final BillingDataSource _billingDataSource;
  final SubscriptionBackendDataSource _backendDataSource;

  final StreamController<EntitlementStatus> _statusController =
      StreamController<EntitlementStatus>.broadcast();

  EntitlementStatus _status = const EntitlementStatus(
    tier: EntitlementTier.free,
    isActive: false,
    source: 'unknown',
  );

  StreamSubscription<EntitlementStatus>? _billingStatusSub;
  StreamSubscription<BillingPurchaseUpdate>? _purchaseUpdatesSub;

  @override
  Future<void> initialize() async {
    await _billingDataSource.initialize();

    _billingStatusSub?.cancel();
    _billingStatusSub = _billingDataSource.watchEntitlementStatus().listen((EntitlementStatus localStatus) {
      _status = localStatus;
      _statusController.add(_status);
    });

    _purchaseUpdatesSub?.cancel();
    _purchaseUpdatesSub = _billingDataSource.watchPurchaseUpdates().listen(_handlePurchaseUpdate);

    await _refreshFromBackend();
  }

  @override
  Future<SubscriptionPlan?> getMonthlyPlan() => _billingDataSource.getMonthlyPlan();

  @override
  Future<EntitlementStatus> getEntitlementStatus() async => _status;

  @override
  Stream<EntitlementStatus> watchEntitlementStatus() => _statusController.stream;

  @override
  Future<bool> purchaseMonthlyPlan() async {
    final SubscriptionPlan? plan = await getMonthlyPlan();
    if (plan == null) {
      return false;
    }

    return _billingDataSource.purchaseMonthlyPlan(plan);
  }

  @override
  Future<void> restorePurchases() async {
    await _billingDataSource.restorePurchases();
    await _refreshFromBackend();
  }

  Future<void> _refreshFromBackend() async {
    try {
      final BackendEntitlementSnapshot? snapshot = await _backendDataSource.fetchPlanStatus();
      if (snapshot != null) {
        _status = snapshot.status;
        _statusController.add(_status);
      }
    } catch (_) {
      // Keep local-temporary state; backend may be unavailable in local/dev.
    }
  }

  Future<void> _handlePurchaseUpdate(BillingPurchaseUpdate update) async {
    switch (update.type) {
      case BillingPurchaseUpdateType.pending:
        _status = const EntitlementStatus(
          tier: EntitlementTier.premiumAi,
          isActive: false,
          source: 'play_billing_pending_verification',
          featureAccess: <PremiumFeature, FeatureEntitlementStatus>{
            PremiumFeature.aiChat: FeatureEntitlementStatus(
              feature: PremiumFeature.aiChat,
              entitled: true,
              allowed: false,
              quota: 0,
              used: 0,
              remaining: 0,
              reason: 'pending_verification',
            ),
            PremiumFeature.aiVoice: FeatureEntitlementStatus(
              feature: PremiumFeature.aiVoice,
              entitled: true,
              allowed: false,
              quota: 0,
              used: 0,
              remaining: 0,
              reason: 'pending_verification',
            ),
          },
        );
        _statusController.add(_status);
        return;
      case BillingPurchaseUpdateType.purchased:
      case BillingPurchaseUpdateType.restored:
        if (update.purchaseToken == null || update.purchaseToken!.isEmpty) {
          _status = const EntitlementStatus(
            tier: EntitlementTier.free,
            isActive: false,
            source: 'play_billing_missing_token',
          );
          _statusController.add(_status);
          return;
        }

        _status = const EntitlementStatus(
          tier: EntitlementTier.premiumAi,
          isActive: false,
          source: 'play_billing_local_pending_server_validation',
          featureAccess: <PremiumFeature, FeatureEntitlementStatus>{
            PremiumFeature.aiChat: FeatureEntitlementStatus(
              feature: PremiumFeature.aiChat,
              entitled: true,
              allowed: false,
              quota: 0,
              used: 0,
              remaining: 0,
              reason: 'pending_verification',
            ),
            PremiumFeature.aiVoice: FeatureEntitlementStatus(
              feature: PremiumFeature.aiVoice,
              entitled: true,
              allowed: false,
              quota: 0,
              used: 0,
              remaining: 0,
              reason: 'pending_verification',
            ),
          },
        );
        _statusController.add(_status);

        try {
          await _backendDataSource.syncPlayPurchase(
            purchaseToken: update.purchaseToken!,
            productId: update.productId,
            orderId: update.orderId,
          );
          await _refreshFromBackend();
        } catch (_) {
          _status = const EntitlementStatus(
            tier: EntitlementTier.free,
            isActive: false,
            source: 'backend_verification_failed',
            featureAccess: <PremiumFeature, FeatureEntitlementStatus>{
              PremiumFeature.aiChat: FeatureEntitlementStatus.unavailable(
                PremiumFeature.aiChat,
              ),
              PremiumFeature.aiVoice: FeatureEntitlementStatus.unavailable(
                PremiumFeature.aiVoice,
              ),
            },
          );
          _statusController.add(_status);
        }
        return;
      case BillingPurchaseUpdateType.canceled:
        _status = const EntitlementStatus(
          tier: EntitlementTier.free,
          isActive: false,
          source: 'play_billing_canceled',
          featureAccess: <PremiumFeature, FeatureEntitlementStatus>{
            PremiumFeature.aiChat: FeatureEntitlementStatus.unavailable(
              PremiumFeature.aiChat,
            ),
            PremiumFeature.aiVoice: FeatureEntitlementStatus.unavailable(
              PremiumFeature.aiVoice,
            ),
          },
        );
        _statusController.add(_status);
        return;
      case BillingPurchaseUpdateType.error:
        _status = const EntitlementStatus(
          tier: EntitlementTier.free,
          isActive: false,
          source: 'play_billing_error',
          featureAccess: <PremiumFeature, FeatureEntitlementStatus>{
            PremiumFeature.aiChat: FeatureEntitlementStatus.unavailable(
              PremiumFeature.aiChat,
            ),
            PremiumFeature.aiVoice: FeatureEntitlementStatus.unavailable(
              PremiumFeature.aiVoice,
            ),
          },
        );
        _statusController.add(_status);
        return;
    }
  }

  @override
  Future<void> dispose() async {
    await _billingStatusSub?.cancel();
    await _purchaseUpdatesSub?.cancel();
    await _billingDataSource.dispose();
    await _statusController.close();
  }
}
