import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase/firebase_service_providers.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../onboarding/data/onboarding_repository.dart';
import '../../data/auth_repository.dart';
import '../../domain/session_state.dart';
import 'session_controller.dart';

final Provider<LocalStorageService> localStorageProvider =
    Provider<LocalStorageService>((Ref ref) => LocalStorageService());

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  return AuthRepository(
    authService: ref.watch(authServiceProvider),
    localStorage: ref.watch(localStorageProvider),
  );
});

final Provider<OnboardingRepository> onboardingRepositoryProvider =
    Provider<OnboardingRepository>((Ref ref) {
      return OnboardingRepository(localStorage: ref.watch(localStorageProvider));
    });

final ChangeNotifierProvider<SessionController> sessionControllerProvider =
    ChangeNotifierProvider<SessionController>((Ref ref) {
      final SessionController controller = SessionController(
        authRepository: ref.watch(authRepositoryProvider),
        onboardingRepository: ref.watch(onboardingRepositoryProvider),
      );

      controller.initialize();
      ref.onDispose(controller.dispose);
      return controller;
    });

final Provider<SessionState> sessionStateProvider = Provider<SessionState>((Ref ref) {
  return ref.watch(sessionControllerProvider).state;
});
