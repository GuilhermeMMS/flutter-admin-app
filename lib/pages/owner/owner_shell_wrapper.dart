// Lead Genius Admin - Shell Wrapper do Owner
// Layout com NavigationDrawer para área do super-admin.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/auth_provider.dart';

class OwnerShellWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const OwnerShellWrapper({super.key, required this.child});

  @override
  ConsumerState<OwnerShellWrapper> createState() => _OwnerShellWrapperState();
}

class _OwnerShellWrapperState extends ConsumerState<OwnerShellWrapper> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard, label: 'Dashboard', path: '/owner/dashboard'),
    _NavItem(icon: Icons.business, label: 'Tenants', path: '/owner/tenants'),
    _NavItem(icon: Icons.people, label: 'Usuários', path: '/owner/users'),
    _NavItem(icon: Icons.history, label: 'Auditoria', path: '/owner/audit'),
    _NavItem(icon: Icons.support_agent, label: 'Suporte', path: '/owner/support'),
    _NavItem(icon: Icons.receipt_long, label: 'Faturamento', path: '/owner/billing'),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    context.go(_navItems[index].path);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].path)) {
        if (_selectedIndex != i) {
          setState(() => _selectedIndex = i);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width >= 1100;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: isWideScreen
          ? null
          : AppBar(
              title: Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text('Admin'),
                ],
              ),
            ),
      drawer: isWideScreen ? null : _buildDrawer(theme, user),
      body: Row(
        children: [
          // Drawer permanente para telas grandes
          if (isWideScreen) _buildDrawer(theme, user),

          // Conteúdo principal
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildDrawer(ThemeData theme, AsyncValue user) {
    final isWideScreen = MediaQuery.of(context).size.width >= 1100;

    return NavigationDrawer(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        _onItemTapped(index);
        if (!isWideScreen) {
          Navigator.pop(context);
        }
      },
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 16, 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.admin_panel_settings, color: theme.colorScheme.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lead Genius', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Super Admin', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                ],
              ),
            ],
          ),
        ),

        const Divider(indent: 28, endIndent: 28),
        const SizedBox(height: 8),

        // Navegação
        ..._navItems.map((item) => NavigationDrawerDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.icon),
          label: Text(item.label),
        )),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Divider(),
        ),

        // Perfil do usuário
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: user.when(
            data: (u) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text(
                  u?.name.isNotEmpty == true ? u!.name[0].toUpperCase() : '?',
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(u?.name ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(u?.email ?? '', style: theme.textTheme.bodySmall),
            ),
            loading: () => const ListTile(
              leading: CircularProgressIndicator(strokeWidth: 2),
              title: Text('Carregando...'),
            ),
            error: (_, __) => const ListTile(
              leading: Icon(Icons.error),
              title: Text('Erro'),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Logout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;

  const _NavItem({required this.icon, required this.label, required this.path});
}
