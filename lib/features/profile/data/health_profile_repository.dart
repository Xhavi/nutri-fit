import '../../../core/services/local_storage_service.dart';
import '../domain/models/health_profile_models.dart';

class HealthProfileRepository {
  HealthProfileRepository({required LocalStorageService localStorage})
    : _localStorage = localStorage;

  final LocalStorageService _localStorage;
  static const String _profileKey = 'health_profile_v1';

  Future<void> saveProfile(WellnessProfile profile) async {
    await _localStorage.setJson(_profileKey, profile.toJson());
  }

  Future<WellnessProfile?> loadProfile() async {
    final Map<String, dynamic>? json = await _localStorage.getJson(_profileKey);
    if (json == null) {
      return null;
    }

    return WellnessProfile.fromJson(json);
  }
}
