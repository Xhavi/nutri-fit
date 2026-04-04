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

class FirebaseSubscriptionBackendDataSource
    implements SubscriptionBackendDataSource {
  FirebaseSubscriptionBackendDataSource({
    required FunctionsService functionsService,
  }) : _functionsService = functionsService;

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

class MockSubscriptionBackendDataSource implements SubscriptionBackendDataSource {
  MockSubscriptionBackendDataSource({
    bool startPremium = false,
  }) : _snapshot = startPremium
            ? SubscriptionBackendMapper.mockPremiumSnapshot()
            : SubscriptionBackendMapper.mockFreeSnapshot();

  BackendEntitlementSnapshot _snapshot;

  @override
  Future<BackendEntitlementSnapshot?> fetchPlanStatus() async => _snapshot;

  @override
  Future<BackendEntitlementSnapshot?> syncPlayPurchase({
    required String purchaseToken,
    required String productId,
    String? orderId,
  }) async {
    _snapshot = SubscriptionBackendMapper.mockPremiumSnapshot(
      provider: 'mock_play_store',
    );
    return _snapshot;
  }
}

class _QuotaTotals {
  const _QuotaTotals({
    required this.totalQuota,
    required this.usedQuota,
  });

  final int? totalQuota;
  final int usedQuota;
}

class SubscriptionBackendMapper {
  SubscriptionBackendMapper._();

  static BackendEntitlementSnapshot mapPlanStatus(Map<String, dynamic> payload) {
    final Map<String, dynamic>? rawSubscription =
        _mapOrNull(payload['subscription']);
    if (rawSubscription != null) {
      return mapSubscriptionRecord(
        rawSubscription,
        planCatalog: _mapOrNull(payload['planCatalog']),
        usage: _mapOrNull(payload['usage']),
      );
    }

    return mockFreeSnapshot(provider: 'backend_unknown');
  }

  static BackendEntitlementSnapshot mapSubscriptionRecord(
    Map<String, dynamic> record, {
    Map<String, dynamic>? planCatalog,
    Map<String, dynamic>? usage,
  }) {
    final String planId = record['planId']?.toString() ?? 'free';
    final String status = record['status']?.toString() ?? 'inactive';
    final String provider = record['provider']?.toString() ?? 'unknown';
    final String? currentPeriodEndAtRaw =
        record['currentPeriodEndAt']?.toString();
    final bool isSubscriptionActive = status == 'active' || status == 'trialing';
    final bool isPremium = planId == 'premium_ai_monthly';

    final Map<PremiumFeature, FeatureEntitlementStatus> featureAccess =
        _buildFeatureAccess(
      record: record,
      planId: planId,
      planCatalog: planCatalog,
      usage: usage,
      isSubscriptionActive: isSubscriptionActive,
    );
    final _QuotaTotals totals = _buildQuotaTotals(featureAccess);

    return BackendEntitlementSnapshot(
      status: EntitlementStatus(
        tier: isPremium ? EntitlementTier.premiumAi : EntitlementTier.free,
        isActive: isSubscriptionActive && isPremium,
        source: 'backend_$provider:$status',
        validUntil: currentPeriodEndAtRaw == null
            ? null
            : DateTime.tryParse(currentPeriodEndAtRaw),
        totalUnits: totals.totalQuota,
        consumedUnits: totals.usedQuota,
        featureAccess: featureAccess,
      ),
      provider: provider,
      currentPeriodEndAt: currentPeriodEndAtRaw == null
          ? null
          : DateTime.tryParse(currentPeriodEndAtRaw),
    );
  }

  static BackendEntitlementSnapshot mockFreeSnapshot({
    String provider = 'mock',
  }) {
    final Map<PremiumFeature, FeatureEntitlementStatus> featureAccess =
        _mockFeatureAccess(isActive: false);

    return BackendEntitlementSnapshot(
      status: EntitlementStatus(
        tier: EntitlementTier.free,
        isActive: false,
        source: provider == 'mock' ? 'mock' : provider,
        featureAccess: featureAccess,
      ),
      provider: provider,
    );
  }

  static BackendEntitlementSnapshot mockPremiumSnapshot({
    String provider = 'mock',
  }) {
    final Map<PremiumFeature, FeatureEntitlementStatus> featureAccess =
        _mockFeatureAccess(isActive: true);
    final _QuotaTotals totals = _buildQuotaTotals(featureAccess);

    return BackendEntitlementSnapshot(
      status: EntitlementStatus(
        tier: EntitlementTier.premiumAi,
        isActive: true,
        source: provider,
        totalUnits: totals.totalQuota,
        consumedUnits: totals.usedQuota,
        featureAccess: featureAccess,
      ),
      provider: provider,
    );
  }

  static Map<PremiumFeature, FeatureEntitlementStatus> _buildFeatureAccess({
    required Map<String, dynamic> record,
    required String planId,
    required bool isSubscriptionActive,
    Map<String, dynamic>? planCatalog,
    Map<String, dynamic>? usage,
  }) {
    final Map<String, dynamic>? entitlements = _mapOrNull(record['entitlements']);

    return Map<PremiumFeature, FeatureEntitlementStatus>.fromEntries(
      PremiumFeature.values.map((PremiumFeature feature) {
        final Map<String, dynamic>? entitlement =
            _mapOrNull(entitlements?[feature.key]);
        final bool entitled = _resolveFeatureEnabled(
          entitlement: entitlement,
          planCatalog: planCatalog,
          planId: planId,
          feature: feature,
        );
        final int quota = _resolveFeatureQuota(
          planCatalog: planCatalog,
          planId: planId,
          feature: feature,
        );
        final int used = _coerceInt(usage?[feature.key]);
        final int remaining = quota <= 0 ? 0 : (quota - used).clamp(0, quota);
        final bool quotaKnown = planCatalog != null;

        String? reason;
        if (!entitled) {
          reason = 'feature_not_entitled';
        } else if (!isSubscriptionActive) {
          reason = 'subscription_not_active';
        } else if (quotaKnown && quota > 0 && remaining <= 0) {
          reason = 'monthly_quota_exceeded';
        }

        final bool allowed = entitled &&
            isSubscriptionActive &&
            (reason == null || (!quotaKnown && quota == 0));

        return MapEntry<PremiumFeature, FeatureEntitlementStatus>(
          feature,
          FeatureEntitlementStatus(
            feature: feature,
            entitled: entitled,
            allowed: allowed,
            quota: quota,
            used: used,
            remaining: remaining,
            reason: reason,
          ),
        );
      }),
    );
  }

  static Map<PremiumFeature, FeatureEntitlementStatus> _mockFeatureAccess({
    required bool isActive,
  }) {
    return <PremiumFeature, FeatureEntitlementStatus>{
      PremiumFeature.aiChat: FeatureEntitlementStatus(
        feature: PremiumFeature.aiChat,
        entitled: isActive,
        allowed: isActive,
        quota: isActive ? 300 : 0,
        used: 0,
        remaining: isActive ? 300 : 0,
        reason: isActive ? null : 'feature_not_entitled',
      ),
      PremiumFeature.aiVoice: FeatureEntitlementStatus(
        feature: PremiumFeature.aiVoice,
        entitled: isActive,
        allowed: isActive,
        quota: isActive ? 60 : 0,
        used: 0,
        remaining: isActive ? 60 : 0,
        reason: isActive ? null : 'feature_not_entitled',
      ),
    };
  }

  static _QuotaTotals _buildQuotaTotals(
    Map<PremiumFeature, FeatureEntitlementStatus> featureAccess,
  ) {
    int totalQuota = 0;
    int usedQuota = 0;
    bool hasAnyQuota = false;

    for (final FeatureEntitlementStatus featureStatus in featureAccess.values) {
      if (!featureStatus.hasQuota) {
        continue;
      }

      hasAnyQuota = true;
      totalQuota += featureStatus.quota;
      usedQuota += featureStatus.used;
    }

    return _QuotaTotals(
      totalQuota: hasAnyQuota ? totalQuota : null,
      usedQuota: usedQuota,
    );
  }

  static bool _resolveFeatureEnabled({
    required PremiumFeature feature,
    required String planId,
    Map<String, dynamic>? entitlement,
    Map<String, dynamic>? planCatalog,
  }) {
    final dynamic explicitEnabled = entitlement?['enabled'];
    if (explicitEnabled is bool) {
      return explicitEnabled;
    }

    final Map<String, dynamic>? featureConfig = _planFeatureConfig(
      planCatalog: planCatalog,
      planId: planId,
      feature: feature,
    );

    return featureConfig?['enabled'] == true;
  }

  static int _resolveFeatureQuota({
    required PremiumFeature feature,
    required String planId,
    Map<String, dynamic>? planCatalog,
  }) {
    final Map<String, dynamic>? featureConfig = _planFeatureConfig(
      planCatalog: planCatalog,
      planId: planId,
      feature: feature,
    );

    return _coerceInt(featureConfig?['monthlyQuota']);
  }

  static Map<String, dynamic>? _planFeatureConfig({
    required PremiumFeature feature,
    required String planId,
    Map<String, dynamic>? planCatalog,
  }) {
    final Map<String, dynamic>? rawPlan = _mapOrNull(planCatalog?[planId]);
    final Map<String, dynamic>? rawFeatures = _mapOrNull(rawPlan?['features']);
    return _mapOrNull(rawFeatures?[feature.key]);
  }

  static Map<String, dynamic>? _mapOrNull(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map<String, dynamic>(
        (dynamic key, dynamic innerValue) =>
            MapEntry<String, dynamic>(key.toString(), innerValue),
      );
    }

    return null;
  }

  static int _coerceInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
