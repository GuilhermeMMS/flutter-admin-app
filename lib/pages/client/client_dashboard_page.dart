// Lead Genius Admin - Dashboard do Cliente
// Tela principal de métricas do tenant.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers/auth_provider.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/loading_widget.dart';
import '../../services/lead_service.dart';

class ClientDashboardPage extends ConsumerStatefulWidget {
  const ClientDashboardPage({super.key});

  @override
  ConsumerState<ClientDashboardPage> createState() =>
      _ClientDashboardPageState();
}

class _ClientDashboardPageState extends ConsumerState<ClientDashboardPage> {
  final LeadService _leadService = LeadService();
  bool _isLoading = true;
  Map<String, int> _leadCounts = {};
  double _totalValue = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final counts = await _leadService.getLeadCountByStatus();
      final value = await _leadService.getTotalEstimatedValue();

      setState(() {
        _leadCounts = counts;
        _totalValue = value;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/client/settings'),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Carregando métricas...')
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Saudação
                    user.when(
                      data: (u) => Text(
                        'Olá, ${u?.name ?? 'Usuário'}!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Veja o resumo do seu negócio',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Cards de estatísticas
                    StatsGrid(
                      cards: [
                        StatsCard(
                          title: 'Total de Leads',
                          value: _leadCounts.values
                              .fold(0, (sum, v) => sum + v)
                              .toString(),
                          icon: Icons.people,
                          color: Colors.blue,
                          onTap: () => context.push('/client/leads'),
                        ),
                        StatsCard(
                          title: 'Leads Novos',
                          value: (_leadCounts['novo'] ?? 0).toString(),
                          icon: Icons.fiber_new,
                          color: Colors.green,
                        ),
                        StatsCard(
                          title: 'Em Negociação',
                          value: (_leadCounts['negociacao'] ?? 0).toString(),
                          icon: Icons.handshake,
                          color: Colors.orange,
                        ),
                        StatsCard(
                          title: 'Valor Pipeline',
                          value: currencyFormat.format(_totalValue),
                          icon: Icons.attach_money,
                          color: Colors.purple,
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
                    _buildQuickActions(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _QuickActionCard(
          icon: Icons.person_add,
          label: 'Novo Lead',
          onTap: () => context.push('/client/leads/new'),
        ),
        _QuickActionCard(
          icon: Icons.inventory_2,
          label: 'Produtos',
          onTap: () => context.push('/client/products'),
        ),
        _QuickActionCard(
          icon: Icons.description,
          label: 'Contratos',
          onTap: () => context.push('/client/contracts'),
        ),
        _QuickActionCard(
          icon: Icons.bar_chart,
          label: 'Relatórios',
          onTap: () => context.push('/client/reports'),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
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
          width: 150,
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
