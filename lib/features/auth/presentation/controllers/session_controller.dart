import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../onboarding/data/onboarding_repository.dart';
import '../../../onboarding/domain/onboarding_profile.dart';
import '../../../profile/data/health_profile_repository.dart';
import '../../data/auth_repository.dart';
import '../../domain/session_state.dart';

class SessionController extends ChangeNotifier {
  SessionController({
    required AuthRepository authRepository,
    required OnboardingRepository onboardingRepository,
    required HealthProfileRepository healthProfileRepository,
  })  : _authRepository = authRepository,
        _onboardingRepository = onboardingRepository,
        _healthProfileRepository = healthProfileRepository {
    _authSubscription =
        _authRepository.authStateChanges().listen(_onAuthStateChanged);
  }

  final AuthRepository _authRepository;
  final OnboardingRepository _onboardingRepository;
  final HealthProfileRepository _healthProfileRepository;

  SessionState _state = SessionState.initial();
  SessionState get state => _state;

  StreamSubscription<String?>? _authSubscription;

  bool _isInitializing = false;

  Future<void> initialize() async {
    if (_isInitializing) {
      return;
    }

    _isInitializing = true;
    _state = SessionState.initial();
    notifyListeners();

    try {
      final String? userId = await _authRepository.getCurrentUserId();
      await _resolveStateForUser(userId);
    } catch (_) {
      _state = const SessionState(status: SessionStatus.unauthenticated);
      notifyListeners();
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    final String userId =
        await _authRepository.signIn(email: email, password: password);
    await _resolveStateForUser(userId);
  }

  Future<void> register(
      {required String email, required String password}) async {
    final String userId =
        await _authRepository.register(email: email, password: password);
    await _resolveStateForUser(userId);
  }

  Future<void> completeOnboarding(OnboardingProfile profile) async {
    final String? userId = _state.userId;
    if (userId == null) {
      return;
    }

    await _onboardingRepository.saveOnboarding(userId, profile);
    await _healthProfileRepository.saveFromOnboardingProfile(profile);
    _state = SessionState(status: SessionStatus.authenticated, userId: userId);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _healthProfileRepository.clearProfile();
    await _authRepository.signOut();
    _state = const SessionState(status: SessionStatus.unauthenticated);
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(String? userId) async {
    if (_isInitializing) {
      return;
    }

    await _resolveStateForUser(userId);
  }

  Future<void> _resolveStateForUser(String? userId) async {
    if (userId == null) {
      _state = const SessionState(status: SessionStatus.unauthenticated);
      notifyListeners();
      return;
    }

    final bool onboardingDone =
        await _onboardingRepository.isOnboardingCompleted(userId);
    if (onboardingDone) {
      await _syncReusableHealthProfile(userId);
    }

    _state = SessionState(
      status: onboardingDone
          ? SessionStatus.authenticated
          : SessionStatus.needsOnboarding,
      userId: userId,
    );
    notifyListeners();
  }

  Future<void> _syncReusableHealthProfile(String userId) async {
    final profile = await _healthProfileRepository.loadProfile();
    if (profile != null && profile.isComplete) {
      return;
    }

    final OnboardingProfile? onboardingProfile =
        await _onboardingRepository.getOnboardingProfile(userId);
    if (onboardingProfile == null) {
      return;
    }

    await _healthProfileRepository.saveFromOnboardingProfile(onboardingProfile);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
