import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_service.dart';

class FirebaseFirestoreService implements FirestoreService {
  FirebaseFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<Map<String, dynamic>?> getUserDocument(String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('users').doc(userId).get();

    return snapshot.data();
  }

  @override
  Future<void> upsertUserDocument({
    required String userId,
    required Map<String, dynamic> data,
  }) {
    return _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }
}
