import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/features/subscriptions/data/adapters/subscription_backend_data_source.dart';
import 'package:nutri_fit/features/subscriptions/domain/models/entitlement_status.dart';

void main() {
  test('mapea acceso por feature y cuota desde getPlanStatus', () {
    final BackendEntitlementSnapshot snapshot =
        SubscriptionBackendMapper.mapPlanStatus(
      <String, dynamic>{
        'subscription': <String, dynamic>{
          'planId': 'premium_ai_monthly',
          'status': 'active',
          'provider': 'play_store',
          'entitlements': <String, dynamic>{
            'ai_chat': <String, dynamic>{'enabled': true},
            'ai_voice': <String, dynamic>{'enabled': true},
          },
        },
        'planCatalog': <String, dynamic>{
          'premium_ai_monthly': <String, dynamic>{
            'features': <String, dynamic>{
              'ai_chat': <String, dynamic>{
                'enabled': true,
                'monthlyQuota': 300,
              },
              'ai_voice': <String, dynamic>{
                'enabled': true,
                'monthlyQuota': 60,
              },
            },
          },
        },
        'usage': <String, dynamic>{
          'ai_chat': 42,
          'ai_voice': 5,
        },
      },
    );

    expect(snapshot.status.tier, EntitlementTier.premiumAi);
    expect(snapshot.status.isActive, isTrue);
    expect(snapshot.status.hasChatAccess, isTrue);
    expect(snapshot.status.hasVoiceAccess, isTrue);
    expect(snapshot.status.chatAccess.remaining, 258);
    expect(snapshot.status.voiceAccess.remaining, 55);
    expect(snapshot.status.totalUnits, 360);
    expect(snapshot.status.consumedUnits, 47);
  });

  test('bloquea features cuando la suscripcion no esta activa', () {
    final BackendEntitlementSnapshot snapshot =
        SubscriptionBackendMapper.mapPlanStatus(
      <String, dynamic>{
        'subscription': <String, dynamic>{
          'planId': 'premium_ai_monthly',
          'status': 'inactive',
          'provider': 'play_store',
          'entitlements': <String, dynamic>{
            'ai_chat': <String, dynamic>{'enabled': true},
            'ai_voice': <String, dynamic>{'enabled': true},
          },
        },
        'planCatalog': <String, dynamic>{
          'premium_ai_monthly': <String, dynamic>{
            'features': <String, dynamic>{
              'ai_chat': <String, dynamic>{
                'enabled': true,
                'monthlyQuota': 300,
              },
              'ai_voice': <String, dynamic>{
                'enabled': true,
                'monthlyQuota': 60,
              },
            },
          },
        },
        'usage': <String, dynamic>{
          'ai_chat': 0,
          'ai_voice': 0,
        },
      },
    );

    expect(snapshot.status.isActive, isFalse);
    expect(snapshot.status.hasChatAccess, isFalse);
    expect(snapshot.status.hasVoiceAccess, isFalse);
    expect(snapshot.status.chatAccess.reason, 'subscription_not_active');
    expect(snapshot.status.voiceAccess.reason, 'subscription_not_active');
  });

  test('mock backend activa premium completo despues de sincronizar compra', () async {
    final MockSubscriptionBackendDataSource backend =
        MockSubscriptionBackendDataSource();

    final BackendEntitlementSnapshot? initial = await backend.fetchPlanStatus();
    expect(initial, isNotNull);
    expect(initial!.status.hasChatAccess, isFalse);
    expect(initial.status.hasVoiceAccess, isFalse);

    await backend.syncPlayPurchase(
      purchaseToken: 'mock-token',
      productId: 'nutrifit_ai_monthly_499',
    );

    final BackendEntitlementSnapshot? synced = await backend.fetchPlanStatus();
    expect(synced, isNotNull);
    expect(synced!.status.hasChatAccess, isTrue);
    expect(synced.status.hasVoiceAccess, isTrue);
    expect(synced.status.chatAccess.quota, 300);
    expect(synced.status.voiceAccess.quota, 60);
  });
}
