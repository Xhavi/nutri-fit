enum EntitlementTier { free, premiumAi }

class FeatureQuotaStatus {
  const FeatureQuotaStatus({
    required this.totalUnits,
    required this.consumedUnits,
  });

  final int? totalUnits;
  final int consumedUnits;

  bool get hasQuota => totalUnits != null;

  int? get remainingUnits {
    if (totalUnits == null) {
      return null;
    }

    final int remaining = totalUnits! - consumedUnits;
    return remaining < 0 ? 0 : remaining;
  }
}

class EntitlementStatus {
  const EntitlementStatus({
    required this.tier,
    required this.isActive,
    required this.source,
    this.validUntil,
    this.aiChat = const FeatureQuotaStatus(totalUnits: null, consumedUnits: 0),
    this.aiVoice = const FeatureQuotaStatus(totalUnits: null, consumedUnits: 0),
  });

  final EntitlementTier tier;
  final bool isActive;

  /// Source used to build this entitlement status.
  /// Expected values: play_billing, mock, unknown.
  final String source;

  final DateTime? validUntil;
  final FeatureQuotaStatus aiChat;
  final FeatureQuotaStatus aiVoice;

  /// Backward-compatible alias for AI chat consumption.
  int get consumedUnits => aiChat.consumedUnits;

  /// Backward-compatible alias for AI chat total quota.
  int? get totalUnits => aiChat.totalUnits;

  bool get hasQuota => aiChat.hasQuota;

  int? get remainingUnits => aiChat.remainingUnits;

  EntitlementStatus copyWith({
    EntitlementTier? tier,
    bool? isActive,
    String? source,
    DateTime? validUntil,
    bool clearValidUntil = false,
    FeatureQuotaStatus? aiChat,
    FeatureQuotaStatus? aiVoice,
  }) {
    return EntitlementStatus(
      tier: tier ?? this.tier,
      isActive: isActive ?? this.isActive,
      source: source ?? this.source,
      validUntil: clearValidUntil ? null : (validUntil ?? this.validUntil),
      aiChat: aiChat ?? this.aiChat,
      aiVoice: aiVoice ?? this.aiVoice,
    );
  }
}
