import '../config/app_config.dart';
import 'firebase_bootstrap.dart';

class AppBootstrapResult {
  const AppBootstrapResult({required this.config, required this.firebase});

  final AppConfig config;
  final FirebaseBootstrapResult firebase;
}

class AppBootstrap {
  const AppBootstrap({FirebaseBootstrap? firebaseBootstrap})
    : _firebaseBootstrap = firebaseBootstrap ?? const FirebaseBootstrap();

  final FirebaseBootstrap _firebaseBootstrap;

  Future<AppBootstrapResult> initialize() async {
    final AppConfig config = AppConfig.fromEnvironment();
    final FirebaseBootstrapResult firebase = await _firebaseBootstrap.initialize(
      config,
    );

    return AppBootstrapResult(config: config, firebase: firebase);
  }
}
