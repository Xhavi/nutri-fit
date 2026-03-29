import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/services/firebase/firebase_service_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  await runZonedGuarded(() async {
    final AppBootstrapResult bootstrap = await const AppBootstrap().initialize();

    runApp(
      ProviderScope(
        overrides: <Override>[
          appConfigProvider.overrideWithValue(bootstrap.config),
          firebaseBootstrapProvider.overrideWithValue(bootstrap.firebase),
        ],
        child: NutriFitApp(startup: bootstrap),
      ),
    );
  }, (Object error, StackTrace stackTrace) {
    debugPrint('Unhandled startup error: $error');
    debugPrintStack(stackTrace: stackTrace);
  });
}
