// Lead Genius Admin - Serviço de Autenticação
// Gerencia todas as operações de autenticação com Supabase.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import '../app/constants.dart';
import '../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Serviço de autenticação
class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Faz login com email e senha
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException(message: 'Falha no login');
      }

      // Salva tokens de forma segura
      await _saveTokens(response.session);

      // Atualiza último login
      await _updateLastLogin(response.user!.id);

      // Registra log de auditoria
      await _logAudit(
        userId: response.user!.id,
        action: AuditActions.login,
        model: 'users',
        modelId: response.user!.id,
      );

      // Retorna dados do usuário
      return await getUserData(response.user!.id);
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Faz login com magic link
  Future<void> signInWithMagicLink({required String email}) async {
    try {
      await supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.supabase.leadgenius://login-callback/',
      );
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Registra novo usuário
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'cliente_admin',
    String? tenantId,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role,
          'tenant_id': tenantId,
        },
      );

      if (response.user == null) {
        throw const AuthException(message: 'Falha no registro');
      }

      // Cria registro na tabela users
      await supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'name': name,
        'role': role,
        'tenant_id': tenantId,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Para cliente_admin, cria também um tenant
      if (role == 'cliente_admin' && tenantId == null) {
        final tenant = await supabase.from('tenants').insert({
          'name': '$name - Empresa',
          'plan': 'free',
          'owner_user_id': response.user!.id,
          'is_active': true,
          'max_users': 1,
          'created_at': DateTime.now().toIso8601String(),
        }).select().single();

        // Atualiza tenant_id do usuário
        await supabase.from('users').update({
          'tenant_id': tenant['id'],
        }).eq('id', response.user!.id);

        // Atualiza metadados do auth
        await supabase.auth.updateUser(
          UserAttributes(data: {'tenant_id': tenant['id']}),
        );
      }

      // Salva tokens
      if (response.session != null) {
        await _saveTokens(response.session);
      }

      return await getUserData(response.user!.id);
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Faz logout
  Future<void> signOut() async {
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        // Registra log de auditoria
        await _logAudit(
          userId: userId,
          action: AuditActions.logout,
          model: 'users',
          modelId: userId,
        );
      }

      await supabase.auth.signOut();
      await _clearTokens();
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Recupera senha
  Future<void> resetPassword({required String email}) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.leadgenius://reset-password/',
      );
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Atualiza senha
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Obtém o usuário atual
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  /// Obtém dados completos do usuário
  Future<UserModel> getUserData(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      // Se não encontrar na tabela, retorna dados básicos
      final user = supabase.auth.currentUser;
      if (user != null) {
        return UserModel(
          id: user.id,
          email: user.email ?? '',
          name: user.userMetadata?['name'] ?? 'Usuário',
          role: user.userMetadata?['role'] ?? 'cliente_user',
          tenantId: user.userMetadata?['tenant_id'],
          createdAt: DateTime.parse(user.createdAt),
        );
      }
      throw handleSupabaseError(e);
    }
  }

  /// Atualiza perfil do usuário
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final response = await supabase
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      // Atualiza metadados do auth
      if (name != null) {
        await supabase.auth.updateUser(
          UserAttributes(data: {'name': name}),
        );
      }

      return UserModel.fromJson(response);
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Verifica se está autenticado
  bool isAuthenticated() {
    return supabase.auth.currentSession != null;
  }

  /// Obtém a role do usuário atual
  String getCurrentRole() {
    final user = supabase.auth.currentUser;
    return user?.userMetadata?['role'] ?? '';
  }

  /// Obtém o tenant_id do usuário atual
  String? getCurrentTenantId() {
    final user = supabase.auth.currentUser;
    return user?.userMetadata?['tenant_id'];
  }

  // ==========================================
  // MÉTODOS PRIVADOS
  // ==========================================

  /// Salva tokens de forma segura
  Future<void> _saveTokens(Session? session) async {
    if (session == null) return;

    await _secureStorage.write(
      key: StorageKeys.accessToken,
      value: session.accessToken,
    );
    await _secureStorage.write(
      key: StorageKeys.refreshToken,
      value: session.refreshToken,
    );
  }

  /// Limpa tokens salvos
  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    await _secureStorage.delete(key: StorageKeys.userId);
    await _secureStorage.delete(key: StorageKeys.tenantId);
    await _secureStorage.delete(key: StorageKeys.userRole);
  }

  /// Atualiza último login
  Future<void> _updateLastLogin(String userId) async {
    try {
      await supabase.from('users').update({
        'last_login': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (_) {
      // Ignora erros de atualização de último login
    }
  }

  /// Registra log de auditoria
  Future<void> _logAudit({
    required String userId,
    required String action,
    required String model,
    String? modelId,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      await supabase.from('audit_logs').insert({
        'user_id': userId,
        'tenant_id': user?.userMetadata?['tenant_id'],
        'action': action,
        'model': model,
        'model_id': modelId,
        'old_value': oldValue,
        'new_value': newValue,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Ignora erros de auditoria para não afetar a operação principal
    }
  }
}
