// Lead Genius Admin - Detalhe do Lead
// Tela de visualização detalhada de um lead.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/lead_model.dart';
import '../../../services/lead_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/modal_confirm.dart';
import '../../../app/constants.dart';

class LeadDetailPage extends ConsumerStatefulWidget {
  final String leadId;

  const LeadDetailPage({super.key, required this.leadId});

  @override
  ConsumerState<LeadDetailPage> createState() => _LeadDetailPageState();
}

class _LeadDetailPageState extends ConsumerState<LeadDetailPage> {
  final LeadService _leadService = LeadService();
  LeadModel? _lead;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLead();
  }

  Future<void> _loadLead() async {
    try {
      final lead = await _leadService.getLeadById(widget.leadId);
      setState(() {
        _lead = lead;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await _leadService.updateLeadStatus(widget.leadId, newStatus);
      _loadLead();
      if (mounted) {
        showSuccessSnackbar(context, 'Status atualizado');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Erro ao atualizar status');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const LoadingWidget(),
      );
    }

    if (_lead == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Lead não encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_lead!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/client/leads/${widget.leadId}/edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Text(
                            _lead!.initials,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 24,
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
                                _lead!.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_lead!.company != null)
                                Text(
                                  _lead!.company!,
                                  style: theme.textTheme.bodyMedium,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Status
                    _buildInfoRow(Icons.flag, 'Status', LeadStatus.displayName(_lead!.status)),
                    if (_lead!.email != null)
                      _buildInfoRow(Icons.email, 'Email', _lead!.email!),
                    if (_lead!.phone != null)
                      _buildInfoRow(Icons.phone, 'Telefone', _lead!.phone!),
                    if (_lead!.source != null)
                      _buildInfoRow(Icons.source, 'Origem', _lead!.source!),
                    if (_lead!.estimatedValue != null)
                      _buildInfoRow(
                        Icons.attach_money,
                        'Valor Estimado',
                        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                            .format(_lead!.estimatedValue),
                      ),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Criado em',
                      dateFormat.format(_lead!.createdAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Alterar status
            Text('Alterar Status', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LeadStatus.all.map((status) {
                final isSelected = _lead!.status == status;
                return ChoiceChip(
                  label: Text(LeadStatus.displayName(status)),
                  selected: isSelected,
                  onSelected: isSelected ? null : (_) => _updateStatus(status),
                );
              }).toList(),
            ),

            if (_lead!.notes != null && _lead!.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Observações', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_lead!.notes!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
