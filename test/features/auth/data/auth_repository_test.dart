import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/core/services/auth/auth_exception.dart';
import 'package:nutri_fit/core/services/auth/auth_service.dart';
import 'package:nutri_fit/core/services/local_storage_service.dart';
import 'package:nutri_fit/features/auth/data/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AuthRepository restores the cached user id when auth service has none',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'auth_cached_user_id': 'cached-user-1',
    });

    final AuthRepository repository = AuthRepository(
      authService: _FakeAuthService(currentUserId: null),
      localStorage: LocalStorageService(),
    );

    expect(await repository.getCurrentUserId(), 'cached-user-1');
  });

  test('AuthRepository throws a clean message for invalid email', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final AuthRepository repository = AuthRepository(
      authService: _FakeAuthService(currentUserId: null),
      localStorage: LocalStorageService(),
    );

    expect(
      () => repository.signIn(email: 'correo-invalido', password: '123456'),
      throwsA(
        isA<AuthException>().having(
          (AuthException error) => error.message,
          'message',
          'Ingresa un correo electronico valido.',
        ),
      ),
    );
  });
}

class _FakeAuthService implements AuthService {
  _FakeAuthService({required this.currentUserId});

  final String? currentUserId;
  final StreamController<String?> _controller =
      StreamController<String?>.broadcast();

  @override
  Stream<String?> authStateChanges() => _controller.stream;

  @override
  Future<String> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return 'new-user';
  }

  @override
  Future<String?> getCurrentUserId() async => currentUserId;

  @override
  Future<String> signInAnonymously() async => 'anon-user';

  @override
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return 'signed-user';
  }

  @override
  Future<void> signOut() async {}
}
