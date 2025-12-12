// Lead Genius Admin - Detalhe do Contrato
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../main.dart';
import '../../../models/contract_model.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/button_primary.dart';
import '../../../app/constants.dart';

class ContractDetailPage extends ConsumerStatefulWidget {
  final String contractId;
  const ContractDetailPage({super.key, required this.contractId});
  @override
  ConsumerState<ContractDetailPage> createState() => _ContractDetailPageState();
}

class _ContractDetailPageState extends ConsumerState<ContractDetailPage> {
  ContractModel? _contract;
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadContract(); }

  Future<void> _loadContract() async {
    try {
      final response = await supabase.from('contracts').select().eq('id', widget.contractId).single();
      setState(() { _contract = ContractModel.fromJson(response); _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy');

    if (_isLoading) return Scaffold(appBar: AppBar(), body: const LoadingWidget());
    if (_contract == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Contrato não encontrado')));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Contrato'), actions: [
        IconButton(icon: const Icon(Icons.edit), onPressed: () => context.push('/client/contracts/${widget.contractId}/edit')),
        IconButton(icon: const Icon(Icons.picture_as_pdf), tooltip: 'Exportar PDF', onPressed: () {}),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(_contract!.customerName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                        child: Text(ContractStatus.displayName(_contract!.status), style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildInfoRow(Icons.tag, 'Número', _contract!.contractNumber ?? 'N/A'),
                    if (_contract!.customerEmail != null) _buildInfoRow(Icons.email, 'Email', _contract!.customerEmail!),
                    if (_contract!.customerPhone != null) _buildInfoRow(Icons.phone, 'Telefone', _contract!.customerPhone!),
                    _buildInfoRow(Icons.calendar_today, 'Início', dateFormat.format(_contract!.startDate)),
                    if (_contract!.endDate != null) _buildInfoRow(Icons.event, 'Término', dateFormat.format(_contract!.endDate!)),
                    const Divider(height: 32),
                    _buildInfoRow(Icons.attach_money, 'Valor Total', currencyFormat.format(_contract!.value)),
                    if (_contract!.discount > 0) _buildInfoRow(Icons.discount, 'Desconto', currencyFormat.format(_contract!.discount)),
                    _buildInfoRow(Icons.monetization_on, 'Valor Final', currencyFormat.format(_contract!.finalValue)),
                    _buildInfoRow(Icons.payment, 'Parcelas', '${_contract!.installments}x de ${currencyFormat.format(_contract!.installmentValue)}'),
                  ],
                ),
              ),
            ),
            if (_contract!.notes != null && _contract!.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Observações', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(_contract!.notes!))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(icon, size: 20, color: Colors.grey), const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value)),
      ]),
    );
  }
}
