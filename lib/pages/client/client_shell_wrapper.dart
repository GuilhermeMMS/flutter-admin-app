// Lead Genius Admin - Shell Wrapper do Cliente
// Layout com NavigationRail/BottomNavigationBar para área do cliente.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/auth_provider.dart';

class ClientShellWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const ClientShellWrapper({super.key, required this.child});

  @override
  ConsumerState<ClientShellWrapper> createState() => _ClientShellWrapperState();
}

class _ClientShellWrapperState extends ConsumerState<ClientShellWrapper> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard, label: 'Dashboard', path: '/client/dashboard'),
    _NavItem(icon: Icons.people, label: 'Leads', path: '/client/leads'),
    _NavItem(icon: Icons.inventory_2, label: 'Produtos', path: '/client/products'),
    _NavItem(icon: Icons.design_services, label: 'Serviços', path: '/client/services'),
    _NavItem(icon: Icons.description, label: 'Contratos', path: '/client/contracts'),
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
    final isWideScreen = MediaQuery.of(context).size.width >= 800;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: Row(
        children: [
          // NavigationRail para telas grandes
          if (isWideScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Icon(Icons.rocket_launch, size: 32, color: theme.colorScheme.primary),
                    const SizedBox(height: 8),
                    Text('Lead Genius', style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.bar_chart),
                          tooltip: 'Relatórios',
                          onPressed: () => context.push('/client/reports'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          tooltip: 'Configurações',
                          onPressed: () => context.push('/client/settings'),
                        ),
                        const SizedBox(height: 8),
                        user.when(
                          data: (u) => CircleAvatar(
                            radius: 16,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            child: Text(
                              u?.name.isNotEmpty == true ? u!.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          loading: () => const CircularProgressIndicator(strokeWidth: 2),
                          error: (_, __) => const Icon(Icons.person),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              destinations: _navItems.map((item) => NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.icon),
                label: Text(item.label),
              )).toList(),
            ),

          // Conteúdo principal
          Expanded(child: widget.child),
        ],
      ),

      // BottomNavigationBar para telas pequenas
      bottomNavigationBar: isWideScreen
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              destinations: _navItems.map((item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.icon),
                label: item.label,
              )).toList(),
            ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;

  const _NavItem({required this.icon, required this.label, required this.path});
}
