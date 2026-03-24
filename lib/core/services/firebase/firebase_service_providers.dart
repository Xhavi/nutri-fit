import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bootstrap/firebase_bootstrap.dart';
import '../../config/app_config.dart';
import '../auth/auth_service.dart';
import '../auth/firebase_auth_service.dart';
import '../auth/mock_auth_service.dart';
import '../firestore/firebase_firestore_service.dart';
import '../firestore/firestore_service.dart';
import '../firestore/mock_firestore_service.dart';
import '../functions/firebase_functions_service.dart';
import '../functions/functions_service.dart';
import '../functions/mock_functions_service.dart';

final Provider<AppConfig> appConfigProvider = Provider<AppConfig>((Ref ref) {
  throw UnimplementedError('appConfigProvider must be overridden in main.dart');
});

final Provider<FirebaseBootstrapResult> firebaseBootstrapProvider =
    Provider<FirebaseBootstrapResult>((Ref ref) {
      throw UnimplementedError(
        'firebaseBootstrapProvider must be overridden in main.dart',
      );
    });

final Provider<bool> useFirebaseMocksProvider = Provider<bool>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  final FirebaseBootstrapResult bootstrap = ref.watch(firebaseBootstrapProvider);

  if (!config.firebaseEnabled) {
    return true;
  }

  if (config.useFirebaseMocks) {
    return true;
  }

  return !bootstrap.initialized;
});

final Provider<AuthService> authServiceProvider = Provider<AuthService>((Ref ref) {
  final bool useMocks = ref.watch(useFirebaseMocksProvider);
  return useMocks ? MockAuthService() : FirebaseAuthService();
});

final Provider<FirestoreService> firestoreServiceProvider =
    Provider<FirestoreService>((Ref ref) {
      final bool useMocks = ref.watch(useFirebaseMocksProvider);
      return useMocks ? MockFirestoreService() : FirebaseFirestoreService();
    });

final Provider<FunctionsService> functionsServiceProvider =
    Provider<FunctionsService>((Ref ref) {
      final bool useMocks = ref.watch(useFirebaseMocksProvider);
      return useMocks ? MockFunctionsService() : FirebaseFunctionsService();
    });
