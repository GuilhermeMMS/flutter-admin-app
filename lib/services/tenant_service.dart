// Lead Genius Admin - Serviço de Tenants (Firebase)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/tenant_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

/// Provider do serviço de tenants
final tenantServiceProvider = Provider<TenantService>((ref) {
  return TenantService(
    ref.read(firestoreServiceProvider),
    ref.read(firestoreProvider),
    ref.read(firebaseAuthProvider),
  );
});

/// Serviço para gerenciamento de tenants (apenas para owners)
class TenantService {
  final FirestoreService _firestoreService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const String _collection = 'tenants';

  TenantService(this._firestoreService, this._firestore, this._auth);

  /// Buscar todos os tenants
  Future<List<TenantModel>> getTenants({String? search}) async {
    var tenants = await _firestoreService.getAll(
      _collection,
      filterByTenant: false, // Owners veem todos
      orderBy: 'created_at',
      descending: true,
    );

    // Filtro por busca
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      tenants = tenants.where((t) {
        final name = (t['name'] ?? '').toString().toLowerCase();
        return name.contains(searchLower);
      }).toList();
    }

    return tenants.map((data) => TenantModel.fromJson(data)).toList();
  }

  /// Buscar tenant por ID
  Future<TenantModel?> getTenantById(String id) async {
    final data = await _firestoreService.getById(_collection, id);
    if (data == null) return null;
    return TenantModel.fromJson(data);
  }

  /// Criar novo tenant
  Future<String> createTenant({
    required String name,
    required String plan,
    required String ownerEmail,
    required String ownerName,
    required String ownerPassword,
  }) async {
    // 1. Cria o tenant
    final tenantId = await _firestoreService.create(
      _collection,
      {
        'name': name,
        'plan': plan,
        'is_active': true,
        'max_users': _getMaxUsersByPlan(plan),
      },
      addTenantId: false,
    );

    // 2. Nota: Para criar usuário com email/senha no Firebase, 
    // normalmente precisa da API Admin ou usar Cloud Functions
    // Por enquanto, o owner pode convidar o usuário depois

    return tenantId;
  }

  /// Atualizar tenant
  Future<void> updateTenant(String id, Map<String, dynamic> data) async {
    await _firestoreService.update(_collection, id, data);
  }

  /// Desativar/Ativar tenant
  Future<void> toggleTenantStatus(String id, bool isActive) async {
    await _firestoreService.update(_collection, id, {'is_active': isActive});
  }

  /// Buscar usuários de um tenant
  Future<List<UserModel>> getTenantUsers(String tenantId) async {
    final users = await _firestoreService.search(
      'users',
      field: 'tenant_id',
      value: tenantId,
      filterByTenant: false,
    );

    return users.map((data) => UserModel.fromJson(data)).toList();
  }

  /// Estatísticas globais
  Future<Map<String, int>> getGlobalStats() async {
    final tenants = await getTenants();
    final users = await _firestoreService.getAll('users', filterByTenant: false);

    return {
      'total_tenants': tenants.length,
      'active_tenants': tenants.where((t) => t.isActive).length,
      'total_users': users.length,
    };
  }

  int _getMaxUsersByPlan(String plan) {
    switch (plan) {
      case 'free': return 1;
      case 'starter': return 5;
      case 'professional': return 20;
      case 'enterprise': return -1; // Ilimitado
      default: return 1;
    }
  }
}
