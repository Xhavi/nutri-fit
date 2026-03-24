abstract class AuthService {
  Stream<String?> authStateChanges();

  Future<String?> getCurrentUserId();

  Future<String> signInAnonymously();

  Future<void> signOut();
}
