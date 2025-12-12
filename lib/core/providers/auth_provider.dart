// Lead Genius Admin - Provider de Autenticação
// Gerencia o estado de autenticação do usuário.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

/// Provider para o serviço de autenticação
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider para o estado de autenticação
final authStateProvider = StreamProvider<User?>((ref) {
  return supabase.auth.onAuthStateChange.map((event) => event.session?.user);
});

/// Provider para verificar se está logado
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull != null;
});

/// Provider para obter o usuário atual do Supabase
final currentSupabaseUserProvider = Provider<User?>((ref) {
  return supabase.auth.currentUser;
});

/// Provider para obter os dados completos do usuário
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final user = supabase.auth.currentUser;
  if (user == null) return null;

  try {
    final response = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return UserModel.fromJson(response);
  } catch (e) {
    // Se não encontrar na tabela users, cria um modelo básico a partir dos metadados
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] ?? 'Usuário',
      role: user.userMetadata?['role'] ?? 'cliente_user',
      tenantId: user.userMetadata?['tenant_id'],
      createdAt: DateTime.parse(user.createdAt),
    );
  }
});

/// Provider para obter a role do usuário atual
final currentUserRoleProvider = Provider<String>((ref) {
  final user = supabase.auth.currentUser;
  if (user == null) return '';
  return user.userMetadata?['role'] ?? 'cliente_user';
});

/// Provider para obter o tenant_id do usuário atual
final currentTenantIdProvider = Provider<String?>((ref) {
  final user = supabase.auth.currentUser;
  if (user == null) return null;
  return user.userMetadata?['tenant_id'];
});

/// Provider para verificar se o usuário é owner
final isOwnerProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role.startsWith('owner');
});

/// Provider para verificar se o usuário é cliente admin
final isClientAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == 'cliente_admin';
});

/// Provider para verificar se o usuário pode escrever
final canWriteProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == 'owner_admin' || role == 'cliente_admin';
});
