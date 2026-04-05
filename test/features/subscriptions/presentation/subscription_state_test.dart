import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/features/subscriptions/domain/models/entitlement_status.dart';
import 'package:nutri_fit/features/subscriptions/presentation/controllers/subscription_state.dart';

void main() {
  test('SubscriptionState lifecycleMessage handles pending verification', () {
    const SubscriptionState state = SubscriptionState(
      status: EntitlementStatus(
        tier: EntitlementTier.premiumAi,
        isActive: false,
        source: 'play:pending_verification',
      ),
    );

    expect(
      state.lifecycleMessage,
      'Procesando compra y validando con servidor...',
    );
  });

  test('SubscriptionState lifecycleMessage handles canceled subscriptions', () {
    const SubscriptionState state = SubscriptionState(
      status: EntitlementStatus(
        tier: EntitlementTier.premiumAi,
        isActive: true,
        source: 'play:canceled',
      ),
    );

    expect(
      state.lifecycleMessage,
      'Tu suscripcion esta cancelada; mantienes premium hasta que termine el periodo activo.',
    );
  });

  test('SubscriptionState lifecycleMessage handles expired subscriptions', () {
    const SubscriptionState state = SubscriptionState(
      status: EntitlementStatus(
        tier: EntitlementTier.premiumAi,
        isActive: false,
        source: 'play:expired',
      ),
    );

    expect(
      state.lifecycleMessage,
      'Tu suscripcion expiro. Puedes reactivarla desde Google Play.',
    );
  });

  test('SubscriptionState lifecycleMessage handles verification failures', () {
    const SubscriptionState state = SubscriptionState(
      status: EntitlementStatus(
        tier: EntitlementTier.premiumAi,
        isActive: false,
        source: 'backend_verification_failed',
      ),
    );

    expect(
      state.lifecycleMessage,
      'No pudimos validar la compra todavia. Intenta restaurar o reintentar en unos minutos.',
    );
  });
}
