import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';

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
  Future<void> signOut() {
    return _auth.signOut();
  }
}
