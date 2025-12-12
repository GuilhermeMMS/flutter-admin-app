// Lead Genius Admin - Dashboard do Owner
// Tela principal do super-admin com métricas globais.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/tenant_service.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/loading_widget.dart';

class OwnerDashboardPage extends ConsumerStatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  ConsumerState<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends ConsumerState<OwnerDashboardPage> {
  final TenantService _tenantService = TenantService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _tenantService.getGlobalStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Global'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadStats();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Carregando estatísticas...')
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visão Geral',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Estatísticas da plataforma',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Cards de estatísticas
                    StatsGrid(
                      cards: [
                        StatsCard(
                          title: 'Total de Tenants',
                          value: (_stats['total_tenants'] ?? 0).toString(),
                          icon: Icons.business,
                          color: Colors.blue,
                          onTap: () => context.push('/owner/tenants'),
                        ),
                        StatsCard(
                          title: 'Tenants Ativos',
                          value: (_stats['active_tenants'] ?? 0).toString(),
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                        StatsCard(
                          title: 'Total de Usuários',
                          value: (_stats['total_users'] ?? 0).toString(),
                          icon: Icons.people,
                          color: Colors.purple,
                          onTap: () => context.push('/owner/users'),
                        ),
                        StatsCard(
                          title: 'Auditoria',
                          value: 'Ver Logs',
                          icon: Icons.history,
                          color: Colors.orange,
                          onTap: () => context.push('/owner/audit'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Ações rápidas
                    Text(
                      'Ações Rápidas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _ActionCard(
                          icon: Icons.add_business,
                          label: 'Novo Tenant',
                          onTap: () => context.push('/owner/tenants/new'),
                        ),
                        _ActionCard(
                          icon: Icons.person_add,
                          label: 'Novo Usuário',
                          onTap: () => context.push('/owner/users'),
                        ),
                        _ActionCard(
                          icon: Icons.support_agent,
                          label: 'Suporte',
                          onTap: () => context.push('/owner/support'),
                        ),
                        _ActionCard(
                          icon: Icons.receipt_long,
                          label: 'Faturamento',
                          onTap: () => context.push('/owner/billing'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
