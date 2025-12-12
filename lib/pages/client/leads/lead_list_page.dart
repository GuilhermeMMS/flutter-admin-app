// Lead Genius Admin - Lista de Leads (Firebase)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../services/lead_service.dart';
import '../../../models/lead_model.dart';
import '../../../widgets/input_text.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/modal_confirm.dart';
import '../../../app/constants.dart';

class LeadListPage extends ConsumerStatefulWidget {
  const LeadListPage({super.key});

  @override
  ConsumerState<LeadListPage> createState() => _LeadListPageState();
}

class _LeadListPageState extends ConsumerState<LeadListPage> {
  List<LeadModel> _leads = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    setState(() => _isLoading = true);
    try {
      final leadService = ref.read(leadServiceProvider);
      final leads = await leadService.getLeads(
        status: _statusFilter,
        search: _searchQuery,
      );
      setState(() {
        _leads = leads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteLead(String id, String name) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Excluir Lead',
      message: 'Deseja realmente excluir o lead "$name"?',
      isDanger: true,
    );

    if (confirmed == true) {
      try {
        final leadService = ref.read(leadServiceProvider);
        await leadService.deleteLead(id);
        showSuccessSnackbar(context, 'Lead excluído com sucesso');
        _loadLeads();
      } catch (e) {
        showErrorSnackbar(context, 'Erro ao excluir lead');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeads,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/client/leads/new'),
        icon: const Icon(Icons.add),
        label: const Text('Novo Lead'),
      ),
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: InputSearch(
                    onChanged: (value) {
                      _searchQuery = value;
                      _loadLeads();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String?>(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filtrar por status',
                  onSelected: (value) {
                    setState(() => _statusFilter = value);
                    _loadLeads();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: null, child: Text('Todos')),
                    ...LeadStatus.all.map((status) => PopupMenuItem(
                          value: status,
                          child: Text(LeadStatus.displayName(status)),
                        )),
                  ],
                ),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _leads.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.people_outline,
                        title: 'Nenhum lead encontrado',
                        subtitle: 'Comece adicionando seu primeiro lead',
                        buttonLabel: 'Adicionar Lead',
                        onButtonPressed: () => context.push('/client/leads/new'),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadLeads,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _leads.length,
                          itemBuilder: (context, index) {
                            final lead = _leads[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                onTap: () => context.push('/client/leads/${lead.id}'),
                                leading: CircleAvatar(
                                  backgroundColor: LeadStatus.color(lead.status).withOpacity(0.1),
                                  child: Text(
                                    lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      color: LeadStatus.color(lead.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  lead.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${lead.company ?? 'Sem empresa'}\n${LeadStatus.displayName(lead.status)}',
                                ),
                                isThreeLine: true,
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('Editar'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 20, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Excluir', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      context.push('/client/leads/${lead.id}/edit');
                                    } else if (value == 'delete') {
                                      _deleteLead(lead.id, lead.name);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
