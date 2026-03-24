import 'package:flutter/material.dart';

import '../../../../shared/layouts/internal_base_layout.dart';
import '../../../../shared/widgets/empty_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InternalBaseLayout(
      title: 'Ajustes',
      currentIndex: 6,
      child: EmptyState(
        title: 'Configuración general',
        description: 'TODO: Integrar preferencias de app, privacidad y notificaciones.',
        icon: Icons.settings_rounded,
      ),
    );
  }
}
