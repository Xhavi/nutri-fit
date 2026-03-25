import '../../../core/services/auth/auth_service.dart';
import '../../../core/services/local_storage_service.dart';

class AuthRepository {
  AuthRepository({required AuthService authService, required LocalStorageService localStorage})
    : _authService = authService,
      _localStorage = localStorage;

  final AuthService _authService;
  final LocalStorageService _localStorage;

  static const String _cachedUserIdKey = 'auth_cached_user_id';

  Stream<String?> authStateChanges() => _authService.authStateChanges();

  Future<String?> getCurrentUserId() async {
    final String? liveUserId = await _authService.getCurrentUserId();
    if (liveUserId != null) {
      await _localStorage.setString(_cachedUserIdKey, liveUserId);
      return liveUserId;
    }

    return _localStorage.getString(_cachedUserIdKey);
  }

  Future<String> signIn({required String email, required String password}) async {
    final String userId = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _localStorage.setString(_cachedUserIdKey, userId);
    return userId;
  }

  Future<String> register({required String email, required String password}) async {
    final String userId = await _authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _localStorage.setString(_cachedUserIdKey, userId);
    return userId;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    await _localStorage.remove(_cachedUserIdKey);
  }
}
