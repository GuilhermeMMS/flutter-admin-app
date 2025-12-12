// Lead Genius Admin - Gestão de Usuários (Cliente)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../widgets/loading_widget.dart';
import '../../../app/constants.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});
  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadUsers(); }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final tenantId = ref.read(currentTenantIdProvider);
      if (tenantId == null) { setState(() => _isLoading = false); return; }
      final response = await supabase.from('users').select().eq('tenant_id', tenantId).order('created_at', ascending: false);
      setState(() { _users = (response as List).map((e) => UserModel.fromJson(e)).toList(); _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Usuários'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers)]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Novo Usuário')),
      body: _isLoading
          ? const LoadingWidget()
          : _users.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.people_outline, size: 64, color: theme.colorScheme.primary.withOpacity(0.3)),
                  const SizedBox(height: 16), Text('Nenhum usuário encontrado', style: theme.textTheme.titleMedium),
                ]))
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: user.isActive ? theme.colorScheme.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: TextStyle(color: user.isActive ? theme.colorScheme.primary : Colors.grey, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${user.email}\n${UserRoles.displayName(user.role)}'),
                          isThreeLine: true,
                          trailing: PopupMenuButton(itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Editar')),
                            PopupMenuItem(value: 'toggle', child: Text(user.isActive ? 'Desativar' : 'Ativar')),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
