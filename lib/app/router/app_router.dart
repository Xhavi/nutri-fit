import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const _BootstrapHomeScreen();
      },
    ),
  ],
);

class _BootstrapHomeScreen extends StatelessWidget {
  const _BootstrapHomeScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('NutriFit bootstrap ready'),
      ),
    );
  }
}
