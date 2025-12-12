// Lead Genius Admin - Relatórios
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../main.dart';
import '../../../widgets/stats_card.dart';
import '../../../widgets/loading_widget.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});
  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _dateRange = DateTimeRange(start: DateTime.now().subtract(const Duration(days: 30)), end: DateTime.now());
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final leads = await supabase.from('leads').select('id, status, estimated_value');
      final contracts = await supabase.from('contracts').select('id, status, final_value');

      double totalLeadValue = 0;
      double totalContractValue = 0;
      int wonLeads = 0;

      for (final lead in leads) {
        if (lead['estimated_value'] != null) totalLeadValue += (lead['estimated_value'] as num).toDouble();
        if (lead['status'] == 'ganho') wonLeads++;
      }
      for (final contract in contracts) {
        if (contract['final_value'] != null) totalContractValue += (contract['final_value'] as num).toDouble();
      }

      setState(() {
        _stats = {
          'total_leads': (leads as List).length,
          'won_leads': wonLeads,
          'total_contracts': (contracts as List).length,
          'total_lead_value': totalLeadValue,
          'total_contract_value': totalContractValue,
        };
        _isLoading = false;
      });
    } catch (e) { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios'), actions: [
        IconButton(icon: const Icon(Icons.download), tooltip: 'Exportar CSV', onPressed: () {}),
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
      ]),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seletor de período
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.date_range),
                      title: const Text('Período'),
                      subtitle: Text('${dateFormat.format(_dateRange!.start)} - ${dateFormat.format(_dateRange!.end)}'),
                      trailing: TextButton(
                        onPressed: () async {
                          final range = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now(), initialDateRange: _dateRange);
                          if (range != null) { setState(() => _dateRange = range); _loadStats(); }
                        },
                        child: const Text('Alterar'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Resumo', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  StatsGrid(cards: [
                    StatsCard(title: 'Total de Leads', value: (_stats['total_leads'] ?? 0).toString(), icon: Icons.people, color: Colors.blue),
                    StatsCard(title: 'Leads Ganhos', value: (_stats['won_leads'] ?? 0).toString(), icon: Icons.emoji_events, color: Colors.green),
                    StatsCard(title: 'Contratos', value: (_stats['total_contracts'] ?? 0).toString(), icon: Icons.description, color: Colors.purple),
                    StatsCard(title: 'Valor Pipeline', value: currencyFormat.format(_stats['total_lead_value'] ?? 0), icon: Icons.trending_up, color: Colors.orange),
                  ]),
                  const SizedBox(height: 24),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Receita Total', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(currencyFormat.format(_stats['total_contract_value'] ?? 0), style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
                          const SizedBox(height: 4),
                          Text('em contratos fechados', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
