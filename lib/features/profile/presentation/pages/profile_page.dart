import 'package:flutter/material.dart';

import '../../../../shared/layouts/internal_base_layout.dart';
import '../../../../shared/widgets/empty_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InternalBaseLayout(
      title: 'Perfil',
      currentIndex: 5,
      child: EmptyState(
        title: 'Perfil de usuario',
        description: 'TODO: Integrar datos personales, objetivos y preferencias.',
        icon: Icons.person_rounded,
      ),
    );
  }
}
