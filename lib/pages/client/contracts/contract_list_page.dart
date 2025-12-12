// Lead Genius Admin - Lista de Contratos
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../main.dart';
import '../../../models/contract_model.dart';
import '../../../widgets/loading_widget.dart';
import '../../../app/constants.dart';

class ContractListPage extends ConsumerStatefulWidget {
  const ContractListPage({super.key});
  @override
  ConsumerState<ContractListPage> createState() => _ContractListPageState();
}

class _ContractListPageState extends ConsumerState<ContractListPage> {
  List<ContractModel> _contracts = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadContracts(); }

  Future<void> _loadContracts() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.from('contracts').select().order('created_at', ascending: false);
      setState(() { _contracts = (response as List).map((e) => ContractModel.fromJson(e)).toList(); _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(title: const Text('Contratos'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadContracts)]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => context.push('/client/contracts/new'), icon: const Icon(Icons.add), label: const Text('Novo Contrato')),
      body: _isLoading ? const LoadingWidget() : _contracts.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.description_outlined, size: 64, color: theme.colorScheme.primary.withOpacity(0.3)),
              const SizedBox(height: 16), Text('Nenhum contrato cadastrado', style: theme.textTheme.titleMedium),
            ]))
          : RefreshIndicator(
              onRefresh: _loadContracts,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _contracts.length,
                itemBuilder: (context, index) {
                  final contract = _contracts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      onTap: () => context.push('/client/contracts/${contract.id}'),
                      leading: CircleAvatar(
                        backgroundColor: contract.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        child: Icon(Icons.description, color: contract.isActive ? Colors.green : Colors.grey),
                      ),
                      title: Text(contract.customerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${contract.contractNumber ?? 'Sem número'}\n${currencyFormat.format(contract.finalValue)}'),
                      isThreeLine: true,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(ContractStatus.displayName(contract.status), style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
