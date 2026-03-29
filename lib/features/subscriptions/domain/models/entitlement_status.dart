enum EntitlementTier { free, premiumAi }

class EntitlementStatus {
  const EntitlementStatus({
    required this.tier,
    required this.isActive,
    required this.source,
    this.validUntil,
    this.consumedUnits = 0,
    this.totalUnits,
  });

  final EntitlementTier tier;
  final bool isActive;

  /// Source used to build this entitlement status.
  /// Expected values: play_billing, mock, unknown.
  final String source;

  final DateTime? validUntil;

  /// Simple quota scaffolding for AI usage visualization.
  final int consumedUnits;
  final int? totalUnits;

  bool get hasQuota => totalUnits != null;

  int? get remainingUnits {
    if (totalUnits == null) {
      return null;
    }

    final int remaining = totalUnits! - consumedUnits;
    return remaining < 0 ? 0 : remaining;
  }
}
