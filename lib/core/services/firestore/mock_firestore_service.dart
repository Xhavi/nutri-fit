import 'firestore_service.dart';

class MockFirestoreService implements FirestoreService {
  final Map<String, Map<String, dynamic>> _users = <String, Map<String, dynamic>>{};

  @override
  Future<Map<String, dynamic>?> getUserDocument(String userId) async {
    return _users[userId];
  }

  @override
  Future<void> upsertUserDocument({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    _users[userId] = <String, dynamic>{...?_users[userId], ...data};
  }
}
