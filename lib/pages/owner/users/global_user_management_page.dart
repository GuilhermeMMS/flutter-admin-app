// Lead Genius Admin - Gestão Global de Usuários
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../models/user_model.dart';
import '../../../widgets/loading_widget.dart';
import '../../../app/constants.dart';

class GlobalUserManagementPage extends ConsumerStatefulWidget {
  const GlobalUserManagementPage({super.key});

  @override
  ConsumerState<GlobalUserManagementPage> createState() => _GlobalUserManagementPageState();
}

class _GlobalUserManagementPageState extends ConsumerState<GlobalUserManagementPage> {
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.from('users').select().order('created_at', ascending: false);
      setState(() {
        _users = (response as List).map((e) => UserModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestão de Usuários'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers)]),
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
                            backgroundColor: user.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                              style: TextStyle(color: user.isActive ? Colors.green : Colors.grey, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${user.email}\n${UserRoles.displayName(user.role)}'),
                          isThreeLine: true,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: user.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(user.isActive ? 'Ativo' : 'Inativo', style: TextStyle(color: user.isActive ? Colors.green : Colors.grey, fontSize: 12)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
