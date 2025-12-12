// Lead Genius Admin - Serviço de Tenants
// Gerencia operações de tenants (para owners).

import '../main.dart';
import '../models/tenant_model.dart';
import '../models/user_model.dart';
import '../core/errors/exceptions.dart';
import 'supabase_service.dart';

/// Serviço de gestão de tenants
class TenantService {
  final SupabaseService _supabaseService = supabaseService;

  /// Lista todos os tenants
  Future<List<TenantModel>> getTenants({
    String? search,
    int? limit,
  }) async {
    try {
      if (!_supabaseService.isOwner) {
        throw const PermissionException(
          message: 'Apenas administradores podem listar tenants',
        );
      }

      var query = supabase.from('tenants').select();

      if (search != null && search.isNotEmpty) {
        query = query.ilike('name', '%$search%');
      }

      query = query.order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return (response as List).map((e) => TenantModel.fromJson(e)).toList();
    } catch (e) {
      if (e is PermissionException) rethrow;
      throw handleSupabaseError(e);
    }
  }

  /// Busca tenant por ID
  Future<TenantModel> getTenantById(String id) async {
    try {
      final response = await supabase
          .from('tenants')
          .select()
          .eq('id', id)
          .single();

      return TenantModel.fromJson(response);
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Atualiza tenant
  Future<TenantModel> updateTenant(String id, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabase
          .from('tenants')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return TenantModel.fromJson(response);
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Lista usuários de um tenant
  Future<List<UserModel>> getTenantUsers(String tenantId) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('tenant_id', tenantId);

      return (response as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Estatísticas globais
  Future<Map<String, dynamic>> getGlobalStats() async {
    try {
      final tenants = await supabase.from('tenants').select('id, is_active, plan');
      final users = await supabase.from('users').select('id, is_active');

      return {
        'total_tenants': (tenants as List).length,
        'active_tenants': tenants.where((t) => t['is_active'] == true).length,
        'total_users': (users as List).length,
      };
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }
}
