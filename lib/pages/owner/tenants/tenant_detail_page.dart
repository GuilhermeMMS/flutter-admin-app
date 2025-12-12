// Lead Genius Admin - Detalhe do Tenant
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/tenant_model.dart';
import '../../../services/tenant_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../app/constants.dart';

class TenantDetailPage extends ConsumerStatefulWidget {
  final String tenantId;
  const TenantDetailPage({super.key, required this.tenantId});

  @override
  ConsumerState<TenantDetailPage> createState() => _TenantDetailPageState();
}

class _TenantDetailPageState extends ConsumerState<TenantDetailPage> {
  final TenantService _tenantService = TenantService();
  TenantModel? _tenant;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTenant();
  }

  Future<void> _loadTenant() async {
    try {
      final tenant = await _tenantService.getTenantById(widget.tenantId);
      setState(() { _tenant = tenant; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    if (_isLoading) return Scaffold(appBar: AppBar(), body: const LoadingWidget());
    if (_tenant == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Tenant não encontrado')));

    return Scaffold(
      appBar: AppBar(title: Text(_tenant!.name)),
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: _tenant!.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          child: Icon(Icons.business, size: 32, color: _tenant!.isActive ? Colors.green : Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_tenant!.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              Text(_tenant!.isActive ? 'Ativo' : 'Inativo', style: TextStyle(color: _tenant!.isActive ? Colors.green : Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildInfoRow(Icons.workspace_premium, 'Plano', TenantPlans.displayName(_tenant!.plan)),
                    _buildInfoRow(Icons.people, 'Máx. Usuários', _tenant!.maxUsers == -1 ? 'Ilimitado' : _tenant!.maxUsers.toString()),
                    _buildInfoRow(Icons.calendar_today, 'Criado em', dateFormat.format(_tenant!.createdAt)),
                  ],
                ),
              ),
            ),
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
          Icon(icon, size: 20, color: Colors.grey), const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
