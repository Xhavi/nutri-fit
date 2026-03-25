import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/services/auth/auth_exception.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/section_header.dart';
import '../controllers/session_providers.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(sessionControllerProvider).register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        context.go(AppRoutePaths.onboarding);
      }
    } on AuthException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'No se pudo registrar la cuenta.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Crear cuenta',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SectionHeader(
              title: 'Regístrate en NutriFit',
              subtitle: 'Crea tu perfil para iniciar tu experiencia personalizada.',
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Nombre completo',
              prefixIcon: Icons.person_outline,
              controller: _nameController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Correo electrónico',
              hintText: 'tu@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Contraseña',
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              controller: _passwordController,
            ),
            if (_errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
            AppButton(
              label: _isLoading ? 'Creando cuenta...' : 'Continuar',
              onPressed: _isLoading ? null : _submit,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutePaths.login),
              child: const Text('Ya tengo cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
