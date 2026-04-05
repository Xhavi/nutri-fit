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

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) {
      return;
    }

    final String? validationError = _validateInputs();
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(sessionControllerProvider).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) {
        context.go(AppRoutePaths.home);
      }
    } on AuthException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'No se pudo iniciar sesion.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateInputs() {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || !_emailPattern.hasMatch(email)) {
      return 'Ingresa un correo electronico valido.';
    }

    if (password.isEmpty) {
      return 'Ingresa tu contrasena para continuar.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Iniciar sesion',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SectionHeader(
              title: 'Acceso a tu cuenta',
              subtitle: 'Ingresa para continuar con tu plan de bienestar.',
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Correo electronico',
              hintText: 'tu@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Contrasena',
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              controller: _passwordController,
            ),
            if (_errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            AppButton(
              label: _isLoading ? 'Entrando...' : 'Entrar',
              onPressed: _isLoading ? null : _submit,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutePaths.register),
              child: const Text('No tienes cuenta? Registrate'),
            ),
          ],
        ),
      ),
    );
  }
}
