import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase/firebase_service_providers.dart';
import '../../application/subscription_service.dart';
import '../../data/adapters/billing_data_source.dart';
import '../../data/adapters/mock_billing_data_source.dart';
import '../../data/adapters/play_billing_data_source.dart';
import '../../data/adapters/subscription_backend_data_source.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'subscription_controller.dart';
import 'subscription_state.dart';

final Provider<bool> billingForceMockProvider = Provider<bool>((Ref ref) {
  return const bool.fromEnvironment('BILLING_USE_MOCK', defaultValue: false);
});

final Provider<bool> useBillingMockProvider = Provider<bool>((Ref ref) {
  return ref.watch(billingForceMockProvider) ||
      ref.watch(useFirebaseMocksProvider);
});

final Provider<BillingDataSource> billingDataSourceProvider = Provider<BillingDataSource>((Ref ref) {
  if (ref.watch(useBillingMockProvider)) {
    return MockBillingDataSource();
  }

  return PlayBillingDataSource();
});

final Provider<SubscriptionBackendDataSource> subscriptionBackendDataSourceProvider =
    Provider<SubscriptionBackendDataSource>((Ref ref) {
      if (ref.watch(useBillingMockProvider)) {
        return MockSubscriptionBackendDataSource();
      }

      return FirebaseSubscriptionBackendDataSource(
        functionsService: ref.watch(functionsServiceProvider),
      );
    });

final Provider<SubscriptionRepository> subscriptionRepositoryProvider =
    Provider<SubscriptionRepository>((Ref ref) {
      return SubscriptionRepositoryImpl(
        billingDataSource: ref.watch(billingDataSourceProvider),
        backendDataSource: ref.watch(subscriptionBackendDataSourceProvider),
      );
    });

final Provider<SubscriptionService> subscriptionServiceProvider = Provider<SubscriptionService>((Ref ref) {
  return SubscriptionService(repository: ref.watch(subscriptionRepositoryProvider));
});

final ChangeNotifierProvider<SubscriptionController> subscriptionControllerProvider =
    ChangeNotifierProvider<SubscriptionController>((Ref ref) {
      final controller = SubscriptionController(service: ref.watch(subscriptionServiceProvider));
      controller.initialize();
      return controller;
    });

final Provider<SubscriptionState> subscriptionStateProvider = Provider<SubscriptionState>((Ref ref) {
  return ref.watch(subscriptionControllerProvider).state;
});

final Provider<bool> hasPremiumAiProvider = Provider<bool>((Ref ref) {
  return ref.watch(subscriptionStateProvider).hasPremium;
});

final Provider<bool> hasAiChatAccessProvider = Provider<bool>((Ref ref) {
  return ref.watch(subscriptionStateProvider).hasChatAccess;
});

final Provider<bool> hasAiVoiceAccessProvider = Provider<bool>((Ref ref) {
  return ref.watch(subscriptionStateProvider).hasVoiceAccess;
});
