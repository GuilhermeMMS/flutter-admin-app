// Lead Genius Admin - Configurações do Cliente
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../widgets/modal_confirm.dart';

class ClientSettingsPage extends ConsumerWidget {
  const ClientSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Perfil
          Card(
            child: user.when(
              data: (u) => ListTile(
                leading: CircleAvatar(backgroundColor: theme.colorScheme.primary.withOpacity(0.1), child: Text(u?.name.isNotEmpty == true ? u!.name[0].toUpperCase() : '?', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold))),
                title: Text(u?.name ?? 'Usuário', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(u?.email ?? ''),
                trailing: TextButton(onPressed: () {}, child: const Text('Editar')),
              ),
              loading: () => const ListTile(title: Text('Carregando...')),
              error: (_, __) => const ListTile(title: Text('Erro ao carregar')),
            ),
          ),
          const SizedBox(height: 16),

          // Tema
          Text('Aparência', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(title: const Text('Claro'), value: ThemeMode.light, groupValue: themeMode, onChanged: (v) => ref.read(themeModeProvider.notifier).setTheme(v!)),
                RadioListTile<ThemeMode>(title: const Text('Escuro'), value: ThemeMode.dark, groupValue: themeMode, onChanged: (v) => ref.read(themeModeProvider.notifier).setTheme(v!)),
                RadioListTile<ThemeMode>(title: const Text('Sistema'), value: ThemeMode.system, groupValue: themeMode, onChanged: (v) => ref.read(themeModeProvider.notifier).setTheme(v!)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Opções
          Text('Opções', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(leading: const Icon(Icons.people), title: const Text('Gestão de Usuários'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/client/users')),
                ListTile(leading: const Icon(Icons.business), title: const Text('Dados da Empresa'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
                ListTile(leading: const Icon(Icons.notifications), title: const Text('Notificações'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout
          ElevatedButton.icon(
            onPressed: () async {
              final confirmed = await showConfirmDialog(context, title: 'Sair', message: 'Deseja sair da conta?');
              if (confirmed == true) {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sair da Conta'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
