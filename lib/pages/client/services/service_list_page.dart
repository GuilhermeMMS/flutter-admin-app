// Lead Genius Admin - Lista de Serviços
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../main.dart';
import '../../../models/service_model.dart';
import '../../../widgets/loading_widget.dart';

class ServiceListPage extends ConsumerStatefulWidget {
  const ServiceListPage({super.key});
  @override
  ConsumerState<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends ConsumerState<ServiceListPage> {
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadServices(); }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.from('services').select().order('created_at', ascending: false);
      setState(() { _services = (response as List).map((e) => ServiceModel.fromJson(e)).toList(); _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(title: const Text('Serviços'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadServices)]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => context.push('/client/services/new'), icon: const Icon(Icons.add), label: const Text('Novo Serviço')),
      body: _isLoading ? const LoadingWidget() : _services.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.design_services_outlined, size: 64, color: theme.colorScheme.primary.withOpacity(0.3)),
              const SizedBox(height: 16), Text('Nenhum serviço cadastrado', style: theme.textTheme.titleMedium),
            ]))
          : RefreshIndicator(
              onRefresh: _loadServices,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: theme.colorScheme.primary.withOpacity(0.1), child: Icon(Icons.design_services, color: theme.colorScheme.primary)),
                      title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${service.billingTypeDisplay}\n${currencyFormat.format(service.price)}'),
                      isThreeLine: true,
                      trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => context.push('/client/services/${service.id}/edit')),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
