import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_scaffold.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Cargando NutriFit...'),
            SizedBox(height: 8),
            Text(
              'TODO: Conectar inicialización real (auth, storage, remote config).',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
