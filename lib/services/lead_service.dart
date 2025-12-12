// Lead Genius Admin - Serviço de Leads (Firebase)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/lead_model.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

/// Provider do serviço de leads
final leadServiceProvider = Provider<LeadService>((ref) {
  return LeadService(ref.read(firestoreServiceProvider));
});

/// Serviço para gerenciamento de leads
class LeadService {
  final FirestoreService _firestoreService;
  static const String _collection = 'leads';

  LeadService(this._firestoreService);

  /// Buscar todos os leads
  Future<List<LeadModel>> getLeads({
    String? status,
    String? search,
  }) async {
    var leads = await _firestoreService.getAll(
      _collection,
      orderBy: 'created_at',
      descending: true,
    );

    // Filtro por status
    if (status != null && status.isNotEmpty) {
      leads = leads.where((l) => l['status'] == status).toList();
    }

    // Filtro por busca
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      leads = leads.where((l) {
        final name = (l['name'] ?? '').toString().toLowerCase();
        final email = (l['email'] ?? '').toString().toLowerCase();
        final company = (l['company'] ?? '').toString().toLowerCase();
        return name.contains(searchLower) ||
            email.contains(searchLower) ||
            company.contains(searchLower);
      }).toList();
    }

    return leads.map((data) => LeadModel.fromJson(data)).toList();
  }

  /// Buscar lead por ID
  Future<LeadModel?> getLeadById(String id) async {
    final data = await _firestoreService.getById(_collection, id);
    if (data == null) return null;
    return LeadModel.fromJson(data);
  }

  /// Criar novo lead
  Future<String> createLead(Map<String, dynamic> data) async {
    return await _firestoreService.create(_collection, data);
  }

  /// Atualizar lead
  Future<void> updateLead(String id, Map<String, dynamic> data) async {
    await _firestoreService.update(_collection, id, data);
  }

  /// Deletar lead
  Future<void> deleteLead(String id) async {
    await _firestoreService.delete(_collection, id);
  }

  /// Atualizar status do lead
  Future<void> updateLeadStatus(String id, String newStatus) async {
    await _firestoreService.update(_collection, id, {
      'status': newStatus,
    });
  }

  /// Contar leads por status
  Future<Map<String, int>> getLeadCountByStatus() async {
    final leads = await getLeads();
    final counts = <String, int>{};

    for (final lead in leads) {
      counts[lead.status] = (counts[lead.status] ?? 0) + 1;
    }

    return counts;
  }

  /// Valor total estimado do pipeline
  Future<double> getTotalPipelineValue() async {
    final leads = await getLeads();
    return leads.fold<double>(
      0,
      (sum, lead) => sum + (lead.estimatedValue ?? 0),
    );
  }

  /// Stream de leads em tempo real
  Stream<List<LeadModel>> streamLeads() {
    return _firestoreService
        .streamCollection(_collection, orderBy: 'created_at', descending: true)
        .map((list) => list.map((data) => LeadModel.fromJson(data)).toList());
  }
}
