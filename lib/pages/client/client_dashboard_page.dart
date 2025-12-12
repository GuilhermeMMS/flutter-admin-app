// Lead Genius Admin - Dashboard do Cliente (Firebase)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/lead_service.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/loading_widget.dart';
import '../../app/constants.dart';

class ClientDashboardPage extends ConsumerStatefulWidget {
  const ClientDashboardPage({super.key});

  @override
  ConsumerState<ClientDashboardPage> createState() => _ClientDashboardPageState();
}

class _ClientDashboardPageState extends ConsumerState<ClientDashboardPage> {
  bool _isLoading = true;
  int _totalLeads = 0;
  Map<String, int> _leadsByStatus = {};
  double _pipelineValue = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final leadService = ref.read(leadServiceProvider);
      
      final leads = await leadService.getLeads();
      final statusCounts = await leadService.getLeadCountByStatus();
      final pipelineValue = await leadService.getTotalPipelineValue();

      setState(() {
        _totalLeads = leads.length;
        _leadsByStatus = statusCounts;
        _pipelineValue = pipelineValue;
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
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      'Visão Geral',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cards de estatísticas
                    StatsGrid(
                      cards: [
                        StatsCard(
                          title: 'Total de Leads',
                          value: _totalLeads.toString(),
                          icon: Icons.people,
                          color: Colors.blue,
                        ),
                        StatsCard(
                          title: 'Leads Novos',
                          value: (_leadsByStatus['novo'] ?? 0).toString(),
                          icon: Icons.fiber_new,
                          color: Colors.green,
                        ),
                        StatsCard(
                          title: 'Em Negociação',
                          value: (_leadsByStatus['negociacao'] ?? 0).toString(),
                          icon: Icons.handshake,
                          color: Colors.orange,
                        ),
                        StatsCard(
                          title: 'Valor Pipeline',
                          value: 'R\$ ${_pipelineValue.toStringAsFixed(0)}',
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
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _QuickActionButton(
                          icon: Icons.person_add,
                          label: 'Novo Lead',
                          onTap: () => context.push('/client/leads/new'),
                        ),
                        _QuickActionButton(
                          icon: Icons.inventory_2,
                          label: 'Novo Produto',
                          onTap: () => context.push('/client/products/new'),
                        ),
                        _QuickActionButton(
                          icon: Icons.description,
                          label: 'Novo Contrato',
                          onTap: () => context.push('/client/contracts/new'),
                        ),
                        _QuickActionButton(
                          icon: Icons.bar_chart,
                          label: 'Relatórios',
                          onTap: () => context.push('/client/reports'),
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

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: theme.colorScheme.onPrimaryContainer),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
