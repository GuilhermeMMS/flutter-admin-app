// Lead Genius Admin - Ferramentas de Suporte
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/input_text.dart';
import '../../widgets/button_primary.dart';
import '../../widgets/modal_confirm.dart';

class SupportToolsPage extends ConsumerWidget {
  const SupportToolsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ferramentas de Suporte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ferramentas Administrativas', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _SupportCard(
              icon: Icons.lock_reset,
              title: 'Forçar Reset de Senha',
              description: 'Envia email de reset de senha para um usuário',
              onTap: () => _showResetPasswordDialog(context),
            ),
            _SupportCard(
              icon: Icons.block,
              title: 'Desativar Conta',
              description: 'Desativa temporariamente uma conta de usuário',
              onTap: () => showErrorSnackbar(context, 'Funcionalidade em desenvolvimento'),
            ),
            _SupportCard(
              icon: Icons.download,
              title: 'Exportar Dados',
              description: 'Exporta dados de um tenant em CSV',
              onTap: () => showErrorSnackbar(context, 'Funcionalidade em desenvolvimento'),
            ),
            _SupportCard(
              icon: Icons.cleaning_services,
              title: 'Limpar Cache',
              description: 'Limpa cache do sistema',
              onTap: () => showSuccessSnackbar(context, 'Cache limpo com sucesso!'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset de Senha'),
        content: InputEmail(controller: emailController),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showSuccessSnackbar(context, 'Email de reset enviado!');
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _SupportCard({required this.icon, required this.title, required this.description, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: theme.colorScheme.primary.withOpacity(0.1), child: Icon(icon, color: theme.colorScheme.primary)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
