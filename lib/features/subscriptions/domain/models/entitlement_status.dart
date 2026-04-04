enum EntitlementTier { free, premiumAi }

enum PremiumFeature { aiChat, aiVoice }

extension PremiumFeatureX on PremiumFeature {
  String get key => switch (this) {
        PremiumFeature.aiChat => 'ai_chat',
        PremiumFeature.aiVoice => 'ai_voice',
      };

  String get label => switch (this) {
        PremiumFeature.aiChat => 'Chat IA',
        PremiumFeature.aiVoice => 'Voz IA',
      };
}

class FeatureEntitlementStatus {
  const FeatureEntitlementStatus({
    required this.feature,
    required this.entitled,
    required this.allowed,
    required this.quota,
    required this.used,
    required this.remaining,
    this.reason,
  });

  const FeatureEntitlementStatus.unavailable(this.feature)
      : entitled = false,
        allowed = false,
        quota = 0,
        used = 0,
        remaining = 0,
        reason = 'feature_status_unavailable';

  final PremiumFeature feature;
  final bool entitled;
  final bool allowed;
  final int quota;
  final int used;
  final int remaining;
  final String? reason;

  bool get hasQuota => quota > 0;

  FeatureEntitlementStatus copyWith({
    bool? entitled,
    bool? allowed,
    int? quota,
    int? used,
    int? remaining,
    String? reason,
    bool clearReason = false,
  }) {
    return FeatureEntitlementStatus(
      feature: feature,
      entitled: entitled ?? this.entitled,
      allowed: allowed ?? this.allowed,
      quota: quota ?? this.quota,
      used: used ?? this.used,
      remaining: remaining ?? this.remaining,
      reason: clearReason ? null : (reason ?? this.reason),
    );
  }
}

class _QuotaSummary {
  const _QuotaSummary({
    required this.totalUnits,
    required this.consumedUnits,
  });

  final int? totalUnits;
  final int consumedUnits;
}

class EntitlementStatus {
  const EntitlementStatus({
    required this.tier,
    required this.isActive,
    required this.source,
    this.validUntil,
    this.consumedUnits = 0,
    this.totalUnits,
    this.featureAccess = const <PremiumFeature, FeatureEntitlementStatus>{},
  });

  static const FeatureEntitlementStatus _defaultChatAccess =
      FeatureEntitlementStatus.unavailable(PremiumFeature.aiChat);
  static const FeatureEntitlementStatus _defaultVoiceAccess =
      FeatureEntitlementStatus.unavailable(PremiumFeature.aiVoice);

  final EntitlementTier tier;
  final bool isActive;
  final String source;
  final DateTime? validUntil;
  final int consumedUnits;
  final int? totalUnits;
  final Map<PremiumFeature, FeatureEntitlementStatus> featureAccess;

  bool get hasQuota => totalUnits != null;

  int? get remainingUnits {
    if (totalUnits == null) {
      return null;
    }

    final int remaining = totalUnits! - consumedUnits;
    return remaining < 0 ? 0 : remaining;
  }

  FeatureEntitlementStatus accessFor(PremiumFeature feature) {
    return featureAccess[feature] ??
        (feature == PremiumFeature.aiChat
            ? _defaultChatAccess
            : _defaultVoiceAccess);
  }

  FeatureEntitlementStatus get chatAccess => accessFor(PremiumFeature.aiChat);
  FeatureEntitlementStatus get voiceAccess => accessFor(PremiumFeature.aiVoice);

  bool get hasChatAccess => chatAccess.allowed;
  bool get hasVoiceAccess => voiceAccess.allowed;

  EntitlementStatus copyWith({
    EntitlementTier? tier,
    bool? isActive,
    String? source,
    DateTime? validUntil,
    bool clearValidUntil = false,
    Map<PremiumFeature, FeatureEntitlementStatus>? featureAccess,
    int? consumedUnits,
    int? totalUnits,
  }) {
    final Map<PremiumFeature, FeatureEntitlementStatus> nextFeatureAccess =
        featureAccess ?? this.featureAccess;
    final _QuotaSummary summary = _summarizeFeatureAccess(nextFeatureAccess);

    return EntitlementStatus(
      tier: tier ?? this.tier,
      isActive: isActive ?? this.isActive,
      source: source ?? this.source,
      validUntil: clearValidUntil ? null : (validUntil ?? this.validUntil),
      featureAccess: nextFeatureAccess,
      consumedUnits: consumedUnits ?? summary.consumedUnits,
      totalUnits: totalUnits ?? summary.totalUnits,
    );
  }

  EntitlementStatus copyWithFeatureStatus(FeatureEntitlementStatus nextStatus) {
    final Map<PremiumFeature, FeatureEntitlementStatus> nextFeatureAccess =
        Map<PremiumFeature, FeatureEntitlementStatus>.from(featureAccess);
    nextFeatureAccess[nextStatus.feature] = nextStatus;
    return copyWith(featureAccess: nextFeatureAccess);
  }

  static _QuotaSummary _summarizeFeatureAccess(
    Map<PremiumFeature, FeatureEntitlementStatus> featureAccess,
  ) {
    int total = 0;
    int used = 0;
    bool hasAnyQuota = false;

    for (final FeatureEntitlementStatus featureStatus in featureAccess.values) {
      if (!featureStatus.hasQuota) {
        continue;
      }

      hasAnyQuota = true;
      total += featureStatus.quota;
      used += featureStatus.used;
    }

    return _QuotaSummary(
      totalUnits: hasAnyQuota ? total : null,
      consumedUnits: used,
    );
  }
}
