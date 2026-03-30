import '../../../../core/services/functions/functions_service.dart';
import '../../domain/models/entitlement_status.dart';

class BackendEntitlementSnapshot {
  const BackendEntitlementSnapshot({
    required this.status,
    required this.provider,
    this.currentPeriodEndAt,
  });

  final EntitlementStatus status;
  final String provider;
  final DateTime? currentPeriodEndAt;
}

abstract class SubscriptionBackendDataSource {
  Future<BackendEntitlementSnapshot?> fetchPlanStatus();

  Future<BackendEntitlementSnapshot?> syncPlayPurchase({
    required String purchaseToken,
    required String productId,
    String? orderId,
  });
}

class FirebaseSubscriptionBackendDataSource implements SubscriptionBackendDataSource {
  FirebaseSubscriptionBackendDataSource({required FunctionsService functionsService})
      : _functionsService = functionsService;

  final FunctionsService _functionsService;

  @override
  Future<BackendEntitlementSnapshot?> fetchPlanStatus() async {
    final payload = await _functionsService.call('getPlanStatus');
    if (payload == null) {
      return null;
    }

    return SubscriptionBackendMapper.mapPlanStatus(payload);
  }

  @override
  Future<BackendEntitlementSnapshot?> syncPlayPurchase({
    required String purchaseToken,
    required String productId,
    String? orderId,
  }) async {
    final payload = await _functionsService.call(
      'syncSubscriptionPurchase',
      payload: <String, dynamic>{
        'provider': 'play_store',
        'receiptToken': purchaseToken,
        'productId': productId,
        if (orderId != null) 'orderId': orderId,
      },
    );

    if (payload == null) {
      return null;
    }

    return SubscriptionBackendMapper.mapSubscriptionRecord(payload);
  }
}

class SubscriptionBackendMapper {
  SubscriptionBackendMapper._();

  static BackendEntitlementSnapshot mapPlanStatus(Map<String, dynamic> payload) {
    final dynamic rawSubscription = payload['subscription'];
    if (rawSubscription is Map<String, dynamic>) {
      return mapSubscriptionRecord(rawSubscription);
    }

    return const BackendEntitlementSnapshot(
      status: EntitlementStatus(
        tier: EntitlementTier.free,
        isActive: false,
        source: 'backend_unknown',
      ),
      provider: 'unknown',
    );
  }

  static BackendEntitlementSnapshot mapSubscriptionRecord(Map<String, dynamic> record) {
    final String planId = record['planId']?.toString() ?? 'free';
    final String status = record['status']?.toString() ?? 'inactive';
    final String provider = record['provider']?.toString() ?? 'unknown';
    final String? currentPeriodEndAtRaw = record['currentPeriodEndAt']?.toString();

    final bool isActive = status == 'active' || status == 'trialing';
    final bool isPremium = planId == 'premium_ai_monthly';

    return BackendEntitlementSnapshot(
      status: EntitlementStatus(
        tier: isPremium ? EntitlementTier.premiumAi : EntitlementTier.free,
        isActive: isActive && isPremium,
        source: 'backend_$provider:$status',
        validUntil: currentPeriodEndAtRaw == null
            ? null
            : DateTime.tryParse(currentPeriodEndAtRaw),
        totalUnits: isActive && isPremium ? 100 : null,
        consumedUnits: 0,
      ),
      provider: provider,
      currentPeriodEndAt: currentPeriodEndAtRaw == null
          ? null
          : DateTime.tryParse(currentPeriodEndAtRaw),
    );
  }
}
