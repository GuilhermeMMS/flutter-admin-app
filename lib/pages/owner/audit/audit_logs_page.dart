// Lead Genius Admin - Logs de Auditoria
// Tela de visualização de logs de auditoria.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../main.dart';
import '../../../models/audit_log_model.dart';
import '../../../widgets/loading_widget.dart';
import '../../../app/constants.dart';

class AuditLogsPage extends ConsumerStatefulWidget {
  const AuditLogsPage({super.key});

  @override
  ConsumerState<AuditLogsPage> createState() => _AuditLogsPageState();
}

class _AuditLogsPageState extends ConsumerState<AuditLogsPage> {
  List<AuditLogModel> _logs = [];
  bool _isLoading = true;
  String? _selectedAction;
  String? _selectedModel;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      var query = supabase.from('audit_logs').select();

      if (_selectedAction != null) {
        query = query.eq('action', _selectedAction!);
      }
      if (_selectedModel != null) {
        query = query.eq('model', _selectedModel!);
      }

      query = query.order('timestamp', ascending: false).limit(100);

      final response = await query;
      setState(() {
        _logs = (response as List).map((e) => AuditLogModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs de Auditoria'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _selectedAction,
                    decoration: const InputDecoration(labelText: 'Ação'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todas')),
                      ...['create', 'update', 'delete', 'login', 'logout'].map(
                        (a) => DropdownMenuItem(
                          value: a,
                          child: Text(AuditActions.displayName(a)),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedAction = v);
                      _loadLogs();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _selectedModel,
                    decoration: const InputDecoration(labelText: 'Modelo'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos')),
                      ...['users', 'tenants', 'leads', 'products', 'contracts'].map(
                        (m) => DropdownMenuItem(value: m, child: Text(m)),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedModel = v);
                      _loadLogs();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _logs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 64,
                              color: theme.colorScheme.primary.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text('Nenhum log encontrado',
                              style: theme.textTheme.titleMedium),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadLogs,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final log = _logs[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: _getActionIcon(log.action),
                                title: Text(
                                  '${log.actionDisplay} - ${log.modelDisplay}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  'Usuário: ${log.userName ?? log.userId}\n'
                                  '${dateFormat.format(log.timestamp)}',
                                ),
                                isThreeLine: true,
                                trailing: log.modelId != null
                                    ? Text(
                                        'ID: ${log.modelId!.substring(0, 8)}...',
                                        style: theme.textTheme.bodySmall,
                                      )
                                    : null,
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

  Widget _getActionIcon(String action) {
    IconData icon;
    Color color;

    switch (action) {
      case 'create':
        icon = Icons.add_circle;
        color = Colors.green;
        break;
      case 'update':
        icon = Icons.edit;
        color = Colors.blue;
        break;
      case 'delete':
        icon = Icons.delete;
        color = Colors.red;
        break;
      case 'login':
        icon = Icons.login;
        color = Colors.teal;
        break;
      case 'logout':
        icon = Icons.logout;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
