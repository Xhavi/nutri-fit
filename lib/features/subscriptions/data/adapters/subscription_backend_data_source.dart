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

  Future<FeatureQuotaStatus?> fetchFeatureQuota({required String feature});
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

  @override
  Future<FeatureQuotaStatus?> fetchFeatureQuota({required String feature}) async {
    final payload = await _functionsService.call(
      'getRemainingQuota',
      payload: <String, dynamic>{'feature': feature},
    );

    if (payload == null) {
      return null;
    }

    return SubscriptionBackendMapper.mapFeatureAccess(payload);
  }
}

class SubscriptionBackendMapper {
  SubscriptionBackendMapper._();

  static BackendEntitlementSnapshot mapPlanStatus(Map<String, dynamic> payload) {
    final dynamic rawSubscription = payload['subscription'];
    if (rawSubscription is Map<String, dynamic>) {
      final dynamic rawUsage = payload['usage'];
      final dynamic rawPlanCatalog = payload['planCatalog'];
      return mapSubscriptionRecord(
        rawSubscription,
        usage: _asStringDynamicMap(rawUsage),
        planCatalog: _asStringDynamicMap(rawPlanCatalog),
      );
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

  static BackendEntitlementSnapshot mapSubscriptionRecord(
    Map<String, dynamic> record, {
    Map<String, dynamic>? usage,
    Map<String, dynamic>? planCatalog,
  }) {
    final String planId = record['planId']?.toString() ?? 'free';
    final String status = record['status']?.toString() ?? 'inactive';
    final String provider = record['provider']?.toString() ?? 'unknown';
    final String? currentPeriodEndAtRaw = record['currentPeriodEndAt']?.toString();

    final bool isActive = status == 'active' || status == 'trialing';
    final bool isPremium = planId == 'premium_ai_monthly';

    final int aiChatQuota = _readPlanFeatureQuota(planCatalog, planId: planId, feature: 'ai_chat');
    final int aiVoiceQuota = _readPlanFeatureQuota(planCatalog, planId: planId, feature: 'ai_voice');
    final int aiChatUsed = _readUsage(usage, 'ai_chat');
    final int aiVoiceUsed = _readUsage(usage, 'ai_voice');

    return BackendEntitlementSnapshot(
      status: EntitlementStatus(
        tier: isPremium ? EntitlementTier.premiumAi : EntitlementTier.free,
        isActive: isActive && isPremium,
        source: 'backend_$provider:$status',
        validUntil: currentPeriodEndAtRaw == null
            ? null
            : DateTime.tryParse(currentPeriodEndAtRaw),
        aiChat: FeatureQuotaStatus(
          totalUnits: isActive && isPremium ? aiChatQuota : null,
          consumedUnits: isActive && isPremium ? aiChatUsed : 0,
        ),
        aiVoice: FeatureQuotaStatus(
          totalUnits: isActive && isPremium ? aiVoiceQuota : null,
          consumedUnits: isActive && isPremium ? aiVoiceUsed : 0,
        ),
      ),
      provider: provider,
      currentPeriodEndAt: currentPeriodEndAtRaw == null
          ? null
          : DateTime.tryParse(currentPeriodEndAtRaw),
    );
  }

  static FeatureQuotaStatus mapFeatureAccess(Map<String, dynamic> payload) {
    final int quota = _readInt(payload['quota']);
    final int used = _readInt(payload['used']);

    return FeatureQuotaStatus(
      totalUnits: quota,
      consumedUnits: used,
    );
  }

  static int _readPlanFeatureQuota(
    Map<String, dynamic>? planCatalog, {
    required String planId,
    required String feature,
  }) {
    if (planCatalog == null) {
      return 0;
    }

    final dynamic rawPlan = planCatalog[planId];
    final Map<String, dynamic>? plan = _asStringDynamicMap(rawPlan);
    if (plan == null) {
      return 0;
    }

    final dynamic rawFeatures = plan['features'];
    final Map<String, dynamic>? features = _asStringDynamicMap(rawFeatures);
    if (features == null) {
      return 0;
    }

    final dynamic rawFeature = features[feature];
    final Map<String, dynamic>? featureMap = _asStringDynamicMap(rawFeature);
    if (featureMap == null) {
      return 0;
    }

    return _readInt(featureMap['monthlyQuota']);
  }

  static int _readUsage(Map<String, dynamic>? usage, String feature) {
    if (usage == null) {
      return 0;
    }

    return _readInt(usage[feature]);
  }

  static Map<String, dynamic>? _asStringDynamicMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }

    if (raw is Map) {
      return raw.map((dynamic key, dynamic value) => MapEntry(key.toString(), value));
    }

    return null;
  }

  static int _readInt(dynamic rawValue) {
    if (rawValue is int) {
      return rawValue;
    }

    if (rawValue is num) {
      return rawValue.toInt();
    }

    if (rawValue is String) {
      return int.tryParse(rawValue) ?? 0;
    }

    return 0;
  }
}
