import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import 'auth_exception.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Stream<String?> authStateChanges() {
    return _auth.authStateChanges().map((User? user) => user?.uid);
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _auth.currentUser?.uid;
  }

  @override
  Future<String> signInAnonymously() async {
    final UserCredential credential = await _auth.signInAnonymously();
    return credential.user!.uid;
  }

  @override
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!.uid;
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'No se pudo iniciar sesión.');
    }
  }

  @override
  Future<String> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!.uid;
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'No se pudo crear la cuenta.');
    }
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }
}
