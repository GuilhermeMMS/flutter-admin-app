// Lead Genius Admin - Lista de Tenants
// Tela de gestão de tenants para super-admin.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/tenant_model.dart';
import '../../../services/tenant_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/modal_confirm.dart';
import '../../../app/constants.dart';

class TenantListPage extends ConsumerStatefulWidget {
  const TenantListPage({super.key});

  @override
  ConsumerState<TenantListPage> createState() => _TenantListPageState();
}

class _TenantListPageState extends ConsumerState<TenantListPage> {
  final TenantService _tenantService = TenantService();
  final _searchController = TextEditingController();

  List<TenantModel> _tenants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    setState(() => _isLoading = true);
    try {
      final tenants = await _tenantService.getTenants(
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );
      setState(() {
        _tenants = tenants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showErrorSnackbar(context, 'Erro ao carregar tenants');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Tenants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTenants,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/owner/tenants/new'),
        icon: const Icon(Icons.add),
        label: const Text('Novo Tenant'),
      ),
      body: Column(
        children: [
          // Busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar tenants...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadTenants();
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _loadTenants(),
            ),
          ),

          // Lista
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _tenants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business_outlined, size: 64,
                              color: theme.colorScheme.primary.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text('Nenhum tenant encontrado',
                              style: theme.textTheme.titleMedium),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTenants,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _tenants.length,
                          itemBuilder: (context, index) {
                            return _TenantCard(
                              tenant: _tenants[index],
                              onTap: () => context.push(
                                '/owner/tenants/${_tenants[index].id}',
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

class _TenantCard extends StatelessWidget {
  final TenantModel tenant;
  final VoidCallback onTap;

  const _TenantCard({required this.tenant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

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
                backgroundColor: tenant.isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                child: Icon(
                  Icons.business,
                  color: tenant.isActive ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenant.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Criado em ${dateFormat.format(tenant.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  TenantPlans.displayName(tenant.plan),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
