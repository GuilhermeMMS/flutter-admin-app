// Lead Genius Admin - Serviço de Leads
// Gerencia operações de leads.

import '../main.dart';
import '../models/lead_model.dart';
import '../core/errors/exceptions.dart';
import 'supabase_service.dart';

/// Serviço de gestão de leads
class LeadService {
  final SupabaseService _supabaseService = supabaseService;

  /// Lista todos os leads do tenant
  Future<List<LeadModel>> getLeads({
    String? status,
    String? ownerId,
    String? search,
    int? limit,
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    try {
      var query = supabase.from('leads').select();

      // Filtra por status
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      // Filtra por responsável
      if (ownerId != null && ownerId.isNotEmpty) {
        query = query.eq('owner_user_id', ownerId);
      }

      // Busca por texto
      if (search != null && search.isNotEmpty) {
        query = query.or('name.ilike.%$search%,email.ilike.%$search%,company.ilike.%$search%');
      }

      // Ordena
      query = query.order(orderBy, ascending: ascending);

      // Limita resultados
      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return (response as List).map((e) => LeadModel.fromJson(e)).toList();
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Busca lead por ID
  Future<LeadModel> getLeadById(String id) async {
    try {
      final response = await supabase
          .from('leads')
          .select()
          .eq('id', id)
          .single();

      return LeadModel.fromJson(response);
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Cria novo lead
  Future<LeadModel> createLead(LeadModel lead) async {
    try {
      final data = lead.toJson();
      data.remove('id');
      data.remove('history');
      
      // Adiciona tenant_id do usuário atual
      data['tenant_id'] = _supabaseService.currentTenantId ?? lead.tenantId;
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabase
          .from('leads')
          .insert(data)
          .select()
          .single();

      // Registra auditoria
      await _logAudit(
        action: 'create',
        modelId: response['id'],
        newValue: response,
      );

      return LeadModel.fromJson(response);
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Atualiza lead existente
  Future<LeadModel> updateLead(String id, Map<String, dynamic> updates) async {
    try {
      // Busca valor anterior para auditoria
      final oldLead = await getLeadById(id);

      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabase
          .from('leads')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      // Registra auditoria
      await _logAudit(
        action: 'update',
        modelId: id,
        oldValue: oldLead.toJson(),
        newValue: response,
      );

      return LeadModel.fromJson(response);
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Atualiza status do lead
  Future<LeadModel> updateLeadStatus(String id, String newStatus) async {
    try {
      final oldLead = await getLeadById(id);
      final oldStatus = oldLead.status;

      final response = await supabase
          .from('leads')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      // Adiciona evento ao histórico
      await supabase.from('lead_events').insert({
        'lead_id': id,
        'type': 'status_change',
        'description': 'Status alterado de $oldStatus para $newStatus',
        'old_value': oldStatus,
        'new_value': newStatus,
        'created_by': _supabaseService.currentUser?.id,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Registra auditoria
      await _logAudit(
        action: 'update',
        modelId: id,
        oldValue: {'status': oldStatus},
        newValue: {'status': newStatus},
      );

      return LeadModel.fromJson(response);
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Deleta lead
  Future<void> deleteLead(String id) async {
    try {
      final oldLead = await getLeadById(id);

      await supabase.from('leads').delete().eq('id', id);

      // Registra auditoria
      await _logAudit(
        action: 'delete',
        modelId: id,
        oldValue: oldLead.toJson(),
      );
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Adiciona nota ao lead
  Future<void> addNote(String leadId, String note) async {
    try {
      await supabase.from('lead_events').insert({
        'lead_id': leadId,
        'type': 'note',
        'description': note,
        'created_by': _supabaseService.currentUser?.id,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Conta leads por status
  Future<Map<String, int>> getLeadCountByStatus() async {
    try {
      final response = await supabase.from('leads').select('status');

      final counts = <String, int>{};
      for (final item in response) {
        final status = item['status'] as String;
        counts[status] = (counts[status] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  /// Calcula valor total estimado de leads ativos
  Future<double> getTotalEstimatedValue() async {
    try {
      final response = await supabase
          .from('leads')
          .select('estimated_value')
          .inFilter('status', ['novo', 'contatado', 'qualificado', 'proposta', 'negociacao']);

      double total = 0;
      for (final item in response) {
        if (item['estimated_value'] != null) {
          total += (item['estimated_value'] as num).toDouble();
        }
      }

      return total;
    } catch (e) {
      throw handleSupabaseError(e);
    }
  }

  // ==========================================
  // MÉTODOS PRIVADOS
  // ==========================================

  Future<void> _logAudit({
    required String action,
    String? modelId,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
  }) async {
    try {
      await supabase.from('audit_logs').insert({
        'user_id': _supabaseService.currentUser?.id,
        'tenant_id': _supabaseService.currentTenantId,
        'action': action,
        'model': 'leads',
        'model_id': modelId,
        'old_value': oldValue,
        'new_value': newValue,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }
}
