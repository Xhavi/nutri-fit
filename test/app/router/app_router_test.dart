import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/app/router/app_router.dart';
import 'package:nutri_fit/core/services/auth/auth_service.dart';
import 'package:nutri_fit/core/services/local_storage_service.dart';
import 'package:nutri_fit/features/auth/data/auth_repository.dart';
import 'package:nutri_fit/features/auth/domain/session_state.dart';
import 'package:nutri_fit/features/auth/presentation/controllers/session_controller.dart';
import 'package:nutri_fit/features/auth/presentation/controllers/session_providers.dart';
import 'package:nutri_fit/features/onboarding/data/onboarding_repository.dart';
import 'package:nutri_fit/features/profile/data/health_profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Router sends unauthenticated users to welcome',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final _FakeSessionController controller = _FakeSessionController(
      const SessionState(status: SessionStatus.unauthenticated),
    );

    await tester.pumpWidget(_RouterTestApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido a NutriFit'), findsOneWidget);
  });

  testWidgets('Router sends users needing onboarding to onboarding',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final _FakeSessionController controller = _FakeSessionController(
      const SessionState(
        status: SessionStatus.needsOnboarding,
        userId: 'user-1',
      ),
    );

    await tester.pumpWidget(_RouterTestApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Onboarding inicial'), findsOneWidget);
  });

  testWidgets('Router sends authenticated users to home',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final _FakeSessionController controller = _FakeSessionController(
      const SessionState(
        status: SessionStatus.authenticated,
        userId: 'user-1',
      ),
    );

    await tester.pumpWidget(_RouterTestApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Actividad y ejercicio'), findsOneWidget);
  });
}

class _RouterTestApp extends StatelessWidget {
  const _RouterTestApp({required this.controller});

  final SessionController controller;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: <Override>[
        sessionControllerProvider.overrideWith((Ref ref) => controller),
      ],
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          return MaterialApp.router(
            routerConfig: ref.watch(appRouterProvider),
          );
        },
      ),
    );
  }
}

class _FakeSessionController extends SessionController {
  _FakeSessionController(SessionState value)
      : _value = value,
        super(
          authRepository: AuthRepository(
            authService: _NoopAuthService(),
            localStorage: LocalStorageService(),
          ),
          onboardingRepository:
              OnboardingRepository(localStorage: LocalStorageService()),
          healthProfileRepository:
              HealthProfileRepository(localStorage: LocalStorageService()),
        );

  SessionState _value;

  @override
  SessionState get state => _value;

  void setSessionState(SessionState value) {
    _value = value;
    notifyListeners();
  }
}

class _NoopAuthService implements AuthService {
  @override
  Stream<String?> authStateChanges() => const Stream<String?>.empty();

  @override
  Future<String> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async =>
      'noop-user';

  @override
  Future<String?> getCurrentUserId() async => null;

  @override
  Future<String> signInAnonymously() async => 'noop-anon';

  @override
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async =>
      'noop-user';

  @override
  Future<void> signOut() async {}
}
