import 'package:firebase_core/firebase_core.dart';

import '../config/app_config.dart';

class FirebaseBootstrapResult {
  const FirebaseBootstrapResult({
    required this.attempted,
    required this.initialized,
    this.error,
  });

  final bool attempted;
  final bool initialized;
  final Object? error;

  bool get shouldUseMocks => !initialized;
}

class FirebaseBootstrap {
  const FirebaseBootstrap();

  Future<FirebaseBootstrapResult> initialize(AppConfig config) async {
    if (!config.firebaseEnabled) {
      return const FirebaseBootstrapResult(
        attempted: false,
        initialized: false,
      );
    }

    try {
      await Firebase.initializeApp();

      return const FirebaseBootstrapResult(
        attempted: true,
        initialized: true,
      );
    } catch (error) {
      return FirebaseBootstrapResult(
        attempted: true,
        initialized: false,
        error: error,
      );
    }
  }
}
