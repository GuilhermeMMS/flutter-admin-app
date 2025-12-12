// Lead Genius Admin - Página de Recuperação de Senha
// Tela para solicitar reset de senha.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/auth_provider.dart';
import '../../widgets/input_text.dart';
import '../../widgets/button_primary.dart';
import '../../widgets/modal_confirm.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.resetPassword(email: _emailController.text.trim());

      if (!mounted) return;

      setState(() => _emailSent = true);
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
            child: _emailSent ? _buildSuccessState(theme) : _buildForm(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState(ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.mark_email_read,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Email enviado!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Verifique sua caixa de entrada e siga as instruções para redefinir sua senha.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ButtonPrimary(
          label: 'Voltar ao login',
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(
            'Recuperar Senha',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Digite seu email para receber um link de redefinição',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          InputEmail(
            controller: _emailController,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 24),

          ButtonPrimary(
            label: 'Enviar link',
            onPressed: _isLoading ? null : _handleReset,
            isLoading: _isLoading,
            icon: Icons.send,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
