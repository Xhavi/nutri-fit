abstract class FirestoreService {
  Future<Map<String, dynamic>?> getUserDocument(String userId);

  Future<void> upsertUserDocument({
    required String userId,
    required Map<String, dynamic> data,
  });
}
