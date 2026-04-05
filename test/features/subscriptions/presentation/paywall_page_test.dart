import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/features/subscriptions/application/subscription_service.dart';
import 'package:nutri_fit/features/subscriptions/domain/models/entitlement_status.dart';
import 'package:nutri_fit/features/subscriptions/domain/models/subscription_plan.dart';
import 'package:nutri_fit/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:nutri_fit/features/subscriptions/presentation/controllers/subscription_controller.dart';
import 'package:nutri_fit/features/subscriptions/presentation/controllers/subscription_providers.dart';
import 'package:nutri_fit/features/subscriptions/presentation/pages/paywall_page.dart';

void main() {
  testWidgets('Paywall disables purchase when the plan is unavailable',
      (WidgetTester tester) async {
    final controller = SubscriptionController(
      service: SubscriptionService(
        repository: _FakeSubscriptionRepository(
          plan: null,
          status: const EntitlementStatus(
            tier: EntitlementTier.free,
            isActive: false,
            source: 'mock',
          ),
        ),
      ),
    );
    await controller.initialize();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          subscriptionControllerProvider.overrideWith((Ref ref) => controller),
        ],
        child: const MaterialApp(home: PaywallPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
          'Producto no disponible todavia en Play Console para este entorno.'),
      findsOneWidget,
    );
    expect(find.text('SKU pendiente de configuracion'), findsOneWidget);

    final FilledButton purchaseButton = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Activar AI Premium'),
        matching: find.byType(FilledButton),
      ),
    );

    expect(purchaseButton.onPressed, isNull);
  });

  testWidgets('Paywall shows dynamic plan metadata when available',
      (WidgetTester tester) async {
    final controller = SubscriptionController(
      service: SubscriptionService(
        repository: _FakeSubscriptionRepository(
          plan: const SubscriptionPlan(
            sku: 'nutrifit_ai_monthly_499',
            title: 'AI Premium Mensual',
            description: 'Chat y voz',
            billingPeriod: 'mensual',
            priceLabel: '\$4.99',
            autoRenewing: true,
          ),
          status: const EntitlementStatus(
            tier: EntitlementTier.free,
            isActive: false,
            source: 'mock',
            featureAccess: <PremiumFeature, FeatureEntitlementStatus>{
              PremiumFeature.aiChat: FeatureEntitlementStatus(
                feature: PremiumFeature.aiChat,
                entitled: false,
                allowed: false,
                quota: 0,
                used: 0,
                remaining: 0,
                reason: 'subscription_not_active',
              ),
            },
          ),
        ),
      ),
    );
    await controller.initialize();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          subscriptionControllerProvider.overrideWith((Ref ref) => controller),
        ],
        child: const MaterialApp(home: PaywallPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AI Premium Mensual · \$4.99'), findsOneWidget);
    expect(find.text('SKU: nutrifit_ai_monthly_499'), findsOneWidget);
    expect(find.text('Renovacion automatica mensual'), findsOneWidget);

    final FilledButton purchaseButton = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Activar AI Premium'),
        matching: find.byType(FilledButton),
      ),
    );

    expect(purchaseButton.onPressed, isNotNull);
  });
}

class _FakeSubscriptionRepository implements SubscriptionRepository {
  _FakeSubscriptionRepository({
    required SubscriptionPlan? plan,
    required EntitlementStatus status,
  })  : _plan = plan,
        _status = status;

  final SubscriptionPlan? _plan;
  final EntitlementStatus _status;

  @override
  Future<void> dispose() async {}

  @override
  Future<EntitlementStatus> getEntitlementStatus() async => _status;

  @override
  Future<SubscriptionPlan?> getMonthlyPlan() async => _plan;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> purchaseMonthlyPlan() async => true;

  @override
  Future<void> refreshAiChatQuota() async {}

  @override
  Future<void> restorePurchases() async {}

  @override
  Stream<EntitlementStatus> watchEntitlementStatus() =>
      const Stream<EntitlementStatus>.empty();
}
