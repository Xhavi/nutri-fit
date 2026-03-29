class SubscriptionPlan {
  const SubscriptionPlan({
    required this.sku,
    required this.title,
    required this.description,
    required this.billingPeriod,
    required this.priceLabel,
    required this.autoRenewing,
  });

  final String sku;
  final String title;
  final String description;
  final String billingPeriod;
  final String priceLabel;
  final bool autoRenewing;
}
