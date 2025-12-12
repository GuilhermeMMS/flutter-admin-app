// Lead Genius Admin - Página de Registro
// Tela de cadastro de novo usuário.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/auth_provider.dart';
import '../../widgets/input_text.dart';
import '../../widgets/button_primary.dart';
import '../../widgets/modal_confirm.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      if (!mounted) return;

      showSuccessSnackbar(context, 'Conta criada com sucesso!');
      context.go('/client/dashboard');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Criar Conta',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preencha os dados para começar',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  InputText(
                    label: 'Nome completo',
                    controller: _nameController,
                    enabled: !_isLoading,
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Nome é obrigatório' : null,
                  ),
                  const SizedBox(height: 16),

                  InputEmail(
                    controller: _emailController,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  InputPassword(
                    controller: _passwordController,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  InputPassword(
                    controller: _confirmPasswordController,
                    label: 'Confirmar senha',
                    enabled: !_isLoading,
                    validator: (v) {
                      if (v?.isEmpty == true) return 'Confirme a senha';
                      if (v != _passwordController.text) {
                        return 'Senhas não conferem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  ButtonPrimary(
                    label: 'Cadastrar',
                    onPressed: _isLoading ? null : _handleRegister,
                    isLoading: _isLoading,
                    icon: Icons.person_add,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
