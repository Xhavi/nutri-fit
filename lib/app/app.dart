import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/bootstrap/app_bootstrap.dart';
import '../core/config/app_environment.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class NutriFitApp extends ConsumerWidget {
  const NutriFitApp({required this.startup, super.key});

  final AppBootstrapResult startup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'NutriFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (BuildContext context, Widget? child) {
        final String environmentLabel =
            startup.config.environment == AppEnvironment.prod ? 'PROD' : 'DEV';

        final bool usingMocks =
            startup.config.useFirebaseMocks || !startup.firebase.initialized;

        final List<Widget> overlays = <Widget>[
          if (child != null) child,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              color: Colors.black87,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'ENV: $environmentLabel · Firebase ${usingMocks ? 'MOCK' : 'LIVE'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ];

        return Stack(children: overlays);
      },
    );
  }
}
