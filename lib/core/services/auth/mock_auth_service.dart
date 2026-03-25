import 'dart:async';

import 'auth_exception.dart';
import 'auth_service.dart';

class MockAuthService implements AuthService {
  final StreamController<String?> _authStateController =
      StreamController<String?>.broadcast();

  static final Map<String, _MockCredential> _usersByEmail =
      <String, _MockCredential>{};

  String? _currentUserId;

  @override
  Stream<String?> authStateChanges() => _authStateController.stream;

  @override
  Future<String?> getCurrentUserId() async => _currentUserId;

  @override
  Future<String> signInAnonymously() async {
    _currentUserId = 'mock-user-id';
    _authStateController.add(_currentUserId);
    return _currentUserId!;
  }

  @override
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final _MockCredential? user = _usersByEmail[email.trim().toLowerCase()];
    if (user == null || user.password != password) {
      throw const AuthException('Credenciales inválidas.');
    }

    _currentUserId = user.userId;
    _authStateController.add(_currentUserId);
    return _currentUserId!;
  }

  @override
  Future<String> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final String normalizedEmail = email.trim().toLowerCase();
    if (_usersByEmail.containsKey(normalizedEmail)) {
      throw const AuthException('Este correo ya está registrado.');
    }

    final String userId = 'mock-${_usersByEmail.length + 1}';
    _usersByEmail[normalizedEmail] = _MockCredential(userId: userId, password: password);
    _currentUserId = userId;
    _authStateController.add(_currentUserId);
    return userId;
  }

  @override
  Future<void> signOut() async {
    _currentUserId = null;
    _authStateController.add(null);
  }
}

class _MockCredential {
  const _MockCredential({required this.userId, required this.password});

  final String userId;
  final String password;
}
