// Lead Genius Admin - Lista de Leads
// Tela de listagem de leads com filtros.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/lead_model.dart';
import '../../../services/lead_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/input_text.dart';
import '../../../widgets/modal_confirm.dart';
import '../../../app/constants.dart';

class LeadListPage extends ConsumerStatefulWidget {
  const LeadListPage({super.key});

  @override
  ConsumerState<LeadListPage> createState() => _LeadListPageState();
}

class _LeadListPageState extends ConsumerState<LeadListPage> {
  final LeadService _leadService = LeadService();
  final _searchController = TextEditingController();

  List<LeadModel> _leads = [];
  bool _isLoading = true;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    setState(() => _isLoading = true);
    try {
      final leads = await _leadService.getLeads(
        status: _selectedStatus,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );
      setState(() {
        _leads = leads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showErrorSnackbar(context, 'Erro ao carregar leads');
      }
    }
  }

  Future<void> _deleteLead(LeadModel lead) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Excluir Lead',
      message: 'Deseja excluir "${lead.name}"?',
      isDanger: true,
    );

    if (confirmed == true) {
      try {
        await _leadService.deleteLead(lead.id);
        _loadLeads();
        if (mounted) {
          showSuccessSnackbar(context, 'Lead excluído');
        }
      } catch (e) {
        if (mounted) {
          showErrorSnackbar(context, 'Erro ao excluir');
        }
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
          // Barra de busca e filtros
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar leads...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _loadLeads();
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _loadLeads(),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String?>(
                  value: _selectedStatus,
                  hint: const Text('Status'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...LeadStatus.all.map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(LeadStatus.displayName(s)),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                    _loadLeads();
                  },
                ),
              ],
            ),
          ),

          // Lista de leads
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _leads.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: theme.colorScheme.primary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum lead encontrado',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadLeads,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _leads.length,
                          itemBuilder: (context, index) {
                            final lead = _leads[index];
                            return _LeadCard(
                              lead: lead,
                              onTap: () =>
                                  context.push('/client/leads/${lead.id}'),
                              onDelete: () => _deleteLead(lead),
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

class _LeadCard extends StatelessWidget {
  final LeadModel lead;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _LeadCard({
    required this.lead,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text(
                  lead.initials,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (lead.company != null)
                      Text(
                        lead.company!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
              _StatusChip(status: lead.status),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Excluir', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    context.push('/client/leads/${lead.id}/edit');
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'novo':
        color = Colors.blue;
        break;
      case 'contatado':
        color = Colors.cyan;
        break;
      case 'qualificado':
        color = Colors.teal;
        break;
      case 'proposta':
        color = Colors.orange;
        break;
      case 'negociacao':
        color = Colors.amber;
        break;
      case 'ganho':
        color = Colors.green;
        break;
      case 'perdido':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        LeadStatus.displayName(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
