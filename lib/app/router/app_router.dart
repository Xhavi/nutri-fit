import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_coach/presentation/ai_coach_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/exercise/presentation/exercise_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/nutrition/presentation/nutrition_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';

class AppRoutePaths {
  AppRoutePaths._();

  static const String splash = '/splash';
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
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutePaths.splash,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutePaths.splash,
      builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.welcome,
      builder: (BuildContext context, GoRouterState state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.login,
      builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.register,
      builder: (BuildContext context, GoRouterState state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.onboarding,
      builder: (BuildContext context, GoRouterState state) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (
        BuildContext context,
        GoRouterState state,
        Widget child,
      ) {
        return _MainNavigationShell(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutePaths.home,
          builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutePaths.nutrition,
          builder: (BuildContext context, GoRouterState state) =>
              const NutritionScreen(),
        ),
        GoRoute(
          path: AppRoutePaths.exercise,
          builder: (BuildContext context, GoRouterState state) =>
              const ExerciseScreen(),
        ),
        GoRoute(
          path: AppRoutePaths.progress,
          builder: (BuildContext context, GoRouterState state) => const ProgressScreen(),
        ),
        GoRoute(
          path: AppRoutePaths.aiCoach,
          builder: (BuildContext context, GoRouterState state) => const AiCoachScreen(),
        ),
        GoRoute(
          path: AppRoutePaths.profile,
          builder: (BuildContext context, GoRouterState state) => const ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutePaths.settings,
          builder: (BuildContext context, GoRouterState state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

class _MainNavigationShell extends StatelessWidget {
  const _MainNavigationShell({required this.child});

  final Widget child;

  static const List<_NavigationDestinationItem> _destinations =
      <_NavigationDestinationItem>[
    _NavigationDestinationItem(
      label: 'Home',
      icon: Icons.home_outlined,
      routePath: AppRoutePaths.home,
    ),
    _NavigationDestinationItem(
      label: 'Nutrition',
      icon: Icons.restaurant_menu_outlined,
      routePath: AppRoutePaths.nutrition,
    ),
    _NavigationDestinationItem(
      label: 'Exercise',
      icon: Icons.fitness_center_outlined,
      routePath: AppRoutePaths.exercise,
    ),
    _NavigationDestinationItem(
      label: 'Progress',
      icon: Icons.show_chart_outlined,
      routePath: AppRoutePaths.progress,
    ),
    _NavigationDestinationItem(
      label: 'Coach',
      icon: Icons.smart_toy_outlined,
      routePath: AppRoutePaths.aiCoach,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final int selectedIndex = _currentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        destinations: _destinations
            .map(
              (_NavigationDestinationItem destination) => NavigationDestination(
                icon: Icon(destination.icon),
                label: destination.label,
              ),
            )
            .toList(),
        onDestinationSelected: (int index) {
          context.go(_destinations[index].routePath);
        },
      ),
    );
  }

  int _currentIndex(String location) {
    for (int index = 0; index < _destinations.length; index++) {
      if (location.startsWith(_destinations[index].routePath)) {
        return index;
      }
    }
    return 0;
  }
}

class _NavigationDestinationItem {
  const _NavigationDestinationItem({
    required this.label,
    required this.icon,
    required this.routePath,
  });

  final String label;
  final IconData icon;
  final String routePath;
}
