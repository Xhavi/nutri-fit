import '../../../core/services/local_storage_service.dart';
import '../domain/onboarding_profile.dart';

class OnboardingRepository {
  OnboardingRepository({required LocalStorageService localStorage})
    : _localStorage = localStorage;

  final LocalStorageService _localStorage;

  String _completedKey(String userId) => 'onboarding_completed_$userId';
  String _profileKey(String userId) => 'onboarding_profile_$userId';

  Future<bool> isOnboardingCompleted(String userId) async {
    return await _localStorage.getBool(_completedKey(userId)) ?? false;
  }

  Future<void> saveOnboarding(String userId, OnboardingProfile profile) async {
    await _localStorage.setJson(_profileKey(userId), profile.toJson());
    await _localStorage.setBool(_completedKey(userId), true);
  }

  Future<OnboardingProfile?> getOnboardingProfile(String userId) async {
    final Map<String, dynamic>? json = await _localStorage.getJson(_profileKey(userId));
    if (json == null) {
      return null;
    }

    return OnboardingProfile.fromJson(json);
  }

  Future<void> clearOnboarding(String userId) async {
    await _localStorage.remove(_profileKey(userId));
    await _localStorage.remove(_completedKey(userId));
  }
}
