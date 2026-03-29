import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_coach/presentation/pages/ai_coach_page.dart';
import '../../features/auth/domain/session_state.dart';
import '../../features/auth/presentation/controllers/session_providers.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/exercise/presentation/pages/exercise_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/nutrition/presentation/pages/nutrition_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/subscriptions/presentation/pages/paywall_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

class AppRoutePaths {
  AppRoutePaths._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';

  static const String home = '/home';
  static const String nutrition = '/nutrition';
  static const String exercise = '/exercise';
  static const String progress = '/progress';
  static const String aiCoach = '/ai-coach';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String paywall = '/paywall';
}

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final sessionController = ref.watch(sessionControllerProvider);

  return GoRouter(
    initialLocation: AppRoutePaths.splash,
    refreshListenable: sessionController,
    routes: <GoRoute>[
      GoRoute(
        path: AppRoutePaths.splash,
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutePaths.welcome,
        name: 'welcome',
        builder: (BuildContext context, GoRouterState state) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutePaths.login,
        name: 'login',
        builder: (BuildContext context, GoRouterState state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutePaths.register,
        name: 'register',
        builder: (BuildContext context, GoRouterState state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutePaths.onboarding,
        name: 'onboarding',
        builder: (BuildContext context, GoRouterState state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutePaths.home,
        name: 'home',
        builder: (BuildContext context, GoRouterState state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutePaths.nutrition,
        name: 'nutrition',
        builder: (BuildContext context, GoRouterState state) => const NutritionPage(),
      ),
      GoRoute(
        path: AppRoutePaths.exercise,
        name: 'exercise',
        builder: (BuildContext context, GoRouterState state) => const ExercisePage(),
      ),
      GoRoute(
        path: AppRoutePaths.progress,
        name: 'progress',
        builder: (BuildContext context, GoRouterState state) => const ProgressPage(),
      ),
      GoRoute(
        path: AppRoutePaths.aiCoach,
        name: 'aiCoach',
        builder: (BuildContext context, GoRouterState state) => const AiCoachPage(),
      ),
      GoRoute(
        path: AppRoutePaths.profile,
        name: 'profile',
        builder: (BuildContext context, GoRouterState state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutePaths.settings,
        name: 'settings',
        builder: (BuildContext context, GoRouterState state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutePaths.paywall,
        name: 'paywall',
        builder: (BuildContext context, GoRouterState state) => const PaywallPage(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final String path = state.uri.path;
      final SessionState sessionState = sessionController.state;

      if (sessionState.status == SessionStatus.initializing) {
        return path == AppRoutePaths.splash ? null : AppRoutePaths.splash;
      }

      final bool isAuthRoute = <String>{
        AppRoutePaths.welcome,
        AppRoutePaths.login,
        AppRoutePaths.register,
      }.contains(path);

      if (sessionState.status == SessionStatus.unauthenticated) {
        return isAuthRoute ? null : AppRoutePaths.welcome;
      }

      if (sessionState.status == SessionStatus.needsOnboarding) {
        return path == AppRoutePaths.onboarding ? null : AppRoutePaths.onboarding;
      }

      if (sessionState.status == SessionStatus.authenticated) {
        if (path == AppRoutePaths.splash || path == AppRoutePaths.onboarding || isAuthRoute) {
          return AppRoutePaths.home;
        }
      }

      return null;
    },
  );
});
