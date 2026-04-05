import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/core/services/auth/mock_auth_service.dart';
import 'package:nutri_fit/core/services/local_storage_service.dart';
import 'package:nutri_fit/features/auth/data/auth_repository.dart';
import 'package:nutri_fit/features/auth/domain/session_state.dart';
import 'package:nutri_fit/features/auth/presentation/controllers/session_controller.dart';
import 'package:nutri_fit/features/onboarding/data/onboarding_repository.dart';
import 'package:nutri_fit/features/onboarding/domain/onboarding_profile.dart';
import 'package:nutri_fit/features/profile/data/health_profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService localStorage;
  late AuthRepository authRepository;
  late OnboardingRepository onboardingRepository;
  late HealthProfileRepository healthProfileRepository;
  late SessionController controller;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    localStorage = LocalStorageService();
    authRepository = AuthRepository(
      authService: MockAuthService(),
      localStorage: localStorage,
    );
    onboardingRepository = OnboardingRepository(localStorage: localStorage);
    healthProfileRepository =
        HealthProfileRepository(localStorage: localStorage);
    controller = SessionController(
      authRepository: authRepository,
      onboardingRepository: onboardingRepository,
      healthProfileRepository: healthProfileRepository,
    );
  });

  tearDown(() {
    controller.dispose();
  });

  test(
      'completeOnboarding syncs a reusable health profile and signOut clears it',
      () async {
    await controller.register(email: 'qa@example.com', password: '123456');

    expect(controller.state.status, SessionStatus.needsOnboarding);

    await controller.completeOnboarding(
      const OnboardingProfile(
        name: 'QA Tester',
        age: 29,
        sex: 'Femenino',
        weightKg: 64,
        heightCm: 168,
        primaryGoal: 'Perder grasa',
        activityLevel: 'Moderado',
        foodRestrictions: 'sin lactosa',
      ),
    );

    final profile = await healthProfileRepository.loadProfile();

    expect(controller.state.status, SessionStatus.authenticated);
    expect(profile, isNotNull);
    expect(profile!.isComplete, isTrue);
    expect(profile.userProfile.name, 'QA Tester');
    expect(profile.userProfile.age, 29);

    await controller.signOut();

    expect(controller.state.status, SessionStatus.unauthenticated);
    expect(await healthProfileRepository.loadProfile(), isNull);
  });

  test(
      'signOut preserves onboarding data and signIn restores the reusable health profile',
      () async {
    const profile = OnboardingProfile(
      name: 'Persist QA',
      age: 31,
      sex: 'Masculino',
      weightKg: 82,
      heightCm: 178,
      primaryGoal: 'Mantener peso',
      activityLevel: 'Moderado',
      foodRestrictions: 'sin gluten',
    );

    await controller.register(email: 'persist@example.com', password: '123456');
    final String persistedUserId = controller.state.userId!;
    await controller.completeOnboarding(profile);
    await controller.signOut();

    expect(controller.state.status, SessionStatus.unauthenticated);
    expect(
      await onboardingRepository.isOnboardingCompleted(persistedUserId),
      isTrue,
    );
    expect(await healthProfileRepository.loadProfile(), isNull);

    await controller.signIn(email: 'persist@example.com', password: '123456');

    final restoredProfile = await healthProfileRepository.loadProfile();

    expect(controller.state.status, SessionStatus.authenticated);
    expect(restoredProfile, isNotNull);
    expect(restoredProfile!.isComplete, isTrue);
    expect(restoredProfile.userProfile.name, 'Persist QA');
    expect(restoredProfile.userProfile.age, 31);
  });
}
