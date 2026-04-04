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

  /// Source used to build this entitlement status.
  /// Expected values: play_billing, mock, unknown.
  final String source;

  final DateTime? validUntil;

  /// Aggregate quota summary for premium surfaces.
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
}
