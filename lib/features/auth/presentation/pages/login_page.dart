import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/section_header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Iniciar sesión',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHeader(
            title: 'Acceso a tu cuenta',
            subtitle: 'Ingresa para continuar con tu plan de bienestar.',
          ),
          const SizedBox(height: 20),
          const AppTextField(
            label: 'Correo electrónico',
            hintText: 'tu@email.com',
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: 12),
          const AppTextField(
            label: 'Contraseña',
            obscureText: true,
            prefixIcon: Icons.lock_outline,
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Entrar',
            onPressed: () {
              // TODO: Reemplazar por autenticación real.
              context.go(AppRoutePaths.home);
            },
          ),
        ],
      ),
    );
  }
}
