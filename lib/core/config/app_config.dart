import 'app_environment.dart';

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.firebaseEnabled,
    required this.useFirebaseMocks,
  });

  final AppEnvironment environment;
  final bool firebaseEnabled;
  final bool useFirebaseMocks;

  static AppConfig fromEnvironment() {
    final AppEnvironment environment = AppEnvironment.fromValue(
      const String.fromEnvironment('APP_ENV', defaultValue: 'dev'),
    );

    final bool firebaseEnabled =
        const bool.fromEnvironment('FIREBASE_ENABLED', defaultValue: false);

    final bool useFirebaseMocks =
        const bool.fromEnvironment('FIREBASE_USE_MOCKS', defaultValue: true);

    return AppConfig(
      environment: environment,
      firebaseEnabled: firebaseEnabled,
      useFirebaseMocks: useFirebaseMocks,
    );
  }
}
