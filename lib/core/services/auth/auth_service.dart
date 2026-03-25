abstract class AuthService {
  Stream<String?> authStateChanges();

  Future<String?> getCurrentUserId();

  Future<String> signInAnonymously();

  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<String> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
