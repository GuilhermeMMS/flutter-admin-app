// Lead Genius Admin - Faturamento
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../main.dart';
import '../../../models/invoice_model.dart';
import '../../../widgets/loading_widget.dart';

class BillingPage extends ConsumerStatefulWidget {
  const BillingPage({super.key});

  @override
  ConsumerState<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends ConsumerState<BillingPage> {
  List<InvoiceModel> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.from('invoices').select().order('created_at', ascending: false);
      setState(() {
        _invoices = (response as List).map((e) => InvoiceModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Faturamento'), actions: [
        IconButton(icon: const Icon(Icons.download), tooltip: 'Exportar CSV', onPressed: () {}),
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadInvoices),
      ]),
      body: _isLoading
          ? const LoadingWidget()
          : _invoices.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: theme.colorScheme.primary.withOpacity(0.3)),
                  const SizedBox(height: 16), Text('Nenhuma fatura encontrada', style: theme.textTheme.titleMedium),
                ]))
              : RefreshIndicator(
                  onRefresh: _loadInvoices,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = _invoices[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: invoice.isPaid ? Colors.green.withOpacity(0.1) : invoice.isOverdue ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            child: Icon(Icons.receipt, color: invoice.isPaid ? Colors.green : invoice.isOverdue ? Colors.red : Colors.orange),
                          ),
                          title: Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Vence: ${dateFormat.format(invoice.dueDate)}\n${currencyFormat.format(invoice.total)}'),
                          isThreeLine: true,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (invoice.isPaid ? Colors.green : invoice.isOverdue ? Colors.red : Colors.orange).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(invoice.statusDisplay, style: TextStyle(color: invoice.isPaid ? Colors.green : invoice.isOverdue ? Colors.red : Colors.orange, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
