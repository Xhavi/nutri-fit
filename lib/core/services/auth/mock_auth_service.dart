import 'dart:async';

import 'auth_service.dart';

class MockAuthService implements AuthService {
  final StreamController<String?> _authStateController =
      StreamController<String?>.broadcast();

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
  Future<void> signOut() async {
    _currentUserId = null;
    _authStateController.add(null);
  }
}
