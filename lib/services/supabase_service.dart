// Lead Genius Admin - Serviço de Supabase
// Serviço central para comunicação com o Supabase.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import '../core/errors/exceptions.dart';

/// Serviço central do Supabase
class SupabaseService {
  /// Cliente do Supabase
  SupabaseClient get client => supabase;

  /// Usuário atual
  User? get currentUser => supabase.auth.currentUser;

  /// Sessão atual
  Session? get currentSession => supabase.auth.currentSession;

  /// Tenant ID do usuário atual
  String? get currentTenantId => currentUser?.userMetadata?['tenant_id'];

  /// Role do usuário atual
  String get currentRole => currentUser?.userMetadata?['role'] ?? '';

  /// Verifica se é owner
  bool get isOwner => currentRole.startsWith('owner');

  /// Verifica se é cliente
  bool get isClient => currentRole.startsWith('cliente');

  // ==========================================
  // MÉTODOS GENÉRICOS DE CRUD
  // ==========================================

  /// Busca todos os registros de uma tabela
  Future<List<Map<String, dynamic>>> getAll(
    String table, {
    String? orderBy,
    bool ascending = true,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    try {
      var query = supabase.from(table).select();

      // Aplica filtros
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }

      // Aplica ordenação
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      // Aplica limite
      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Busca um registro por ID
  Future<Map<String, dynamic>> getById(String table, String id) async {
    try {
      final response = await supabase
          .from(table)
          .select()
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Cria um novo registro
  Future<Map<String, dynamic>> create(
    String table,
    Map<String, dynamic> data, {
    bool logAudit = true,
  }) async {
    try {
      // Adiciona tenant_id se necessário
      if (isClient && currentTenantId != null && !data.containsKey('tenant_id')) {
        data['tenant_id'] = currentTenantId;
      }

      // Adiciona timestamps
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabase
          .from(table)
          .insert(data)
          .select()
          .single();

      // Registra auditoria
      if (logAudit) {
        await _logAudit(
          action: 'create',
          model: table,
          modelId: response['id'],
          newValue: response,
        );
      }

      return response;
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Atualiza um registro
  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data, {
    bool logAudit = true,
  }) async {
    try {
      // Busca valor antigo para auditoria
      Map<String, dynamic>? oldValue;
      if (logAudit) {
        try {
          oldValue = await getById(table, id);
        } catch (_) {}
      }

      // Adiciona timestamp de atualização
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabase
          .from(table)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      // Registra auditoria
      if (logAudit) {
        await _logAudit(
          action: 'update',
          model: table,
          modelId: id,
          oldValue: oldValue,
          newValue: response,
        );
      }

      return response;
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Deleta um registro
  Future<void> delete(
    String table,
    String id, {
    bool logAudit = true,
  }) async {
    try {
      // Busca valor antigo para auditoria
      Map<String, dynamic>? oldValue;
      if (logAudit) {
        try {
          oldValue = await getById(table, id);
        } catch (_) {}
      }

      await supabase.from(table).delete().eq('id', id);

      // Registra auditoria
      if (logAudit) {
        await _logAudit(
          action: 'delete',
          model: table,
          modelId: id,
          oldValue: oldValue,
        );
      }
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  // ==========================================
  // MÉTODOS DE BUSCA AVANÇADA
  // ==========================================

  /// Busca com texto livre
  Future<List<Map<String, dynamic>>> search(
    String table,
    String column,
    String query, {
    int limit = 20,
  }) async {
    try {
      final response = await supabase
          .from(table)
          .select()
          .ilike(column, '%$query%')
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Busca com filtro de data
  Future<List<Map<String, dynamic>>> getByDateRange(
    String table, {
    required String dateColumn,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? additionalFilters,
  }) async {
    try {
      var query = supabase
          .from(table)
          .select()
          .gte(dateColumn, startDate.toIso8601String())
          .lte(dateColumn, endDate.toIso8601String());

      if (additionalFilters != null) {
        for (final entry in additionalFilters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Conta registros
  Future<int> count(String table, {Map<String, dynamic>? filters}) async {
    try {
      var query = supabase.from(table).select('id');

      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }

      final response = await query;
      return (response as List).length;
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  // ==========================================
  // MÉTODOS DE STORAGE
  // ==========================================

  /// Faz upload de arquivo
  Future<String> uploadFile(
    String bucket,
    String path,
    List<int> fileBytes, {
    String? contentType,
  }) async {
    try {
      await supabase.storage.from(bucket).uploadBinary(
        path,
        fileBytes as dynamic,
        fileOptions: FileOptions(contentType: contentType),
      );

      return supabase.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Deleta arquivo
  Future<void> deleteFile(String bucket, String path) async {
    try {
      await supabase.storage.from(bucket).remove([path]);
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Obtém URL pública do arquivo
  String getPublicUrl(String bucket, String path) {
    return supabase.storage.from(bucket).getPublicUrl(path);
  }

  // ==========================================
  // MÉTODOS PRIVADOS
  // ==========================================

  /// Registra log de auditoria
  Future<void> _logAudit({
    required String action,
    required String model,
    String? modelId,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
  }) async {
    try {
      if (currentUser == null) return;

      await supabase.from('audit_logs').insert({
        'user_id': currentUser!.id,
        'tenant_id': currentTenantId,
        'action': action,
        'model': model,
        'model_id': modelId,
        'old_value': oldValue,
        'new_value': newValue,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Ignora erros de auditoria
    }
  }
}

/// Instância global do serviço
final supabaseService = SupabaseService();
