// Lead Genius Admin - Serviço do Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';

/// Provider do serviço do Firestore
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(
    ref.read(firestoreProvider),
    ref.read(firebaseAuthProvider),
  );
});

/// Serviço genérico para operações no Firestore
class FirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreService(this._firestore, this._auth);

  /// Obtém o tenant_id do usuário atual
  Future<String?> get currentTenantId async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data()?['tenant_id'];
  }

  /// Obtém a role do usuário atual
  Future<String?> get currentUserRole async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data()?['role'];
  }

  /// Verifica se é owner
  Future<bool> get isOwner async {
    final role = await currentUserRole;
    return role?.startsWith('owner') ?? false;
  }

  // ==========================================
  // OPERAÇÕES GENÉRICAS
  // ==========================================

  /// Buscar todos os documentos de uma coleção (com filtro de tenant)
  Future<List<Map<String, dynamic>>> getAll(
    String collection, {
    bool filterByTenant = true,
    String? orderBy,
    bool descending = true,
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    // Filtra por tenant se necessário
    if (filterByTenant && !(await isOwner)) {
      final tenantId = await currentTenantId;
      if (tenantId != null) {
        query = query.where('tenant_id', isEqualTo: tenantId);
      }
    }

    // Ordenação
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    // Limite
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// Buscar documento por ID
  Future<Map<String, dynamic>?> getById(String collection, String id) async {
    final doc = await _firestore.collection(collection).doc(id).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  /// Criar documento
  Future<String> create(
    String collection,
    Map<String, dynamic> data, {
    String? id,
    bool addTenantId = true,
  }) async {
    final docData = {...data};

    // Adiciona tenant_id se necessário
    if (addTenantId && !(await isOwner)) {
      final tenantId = await currentTenantId;
      if (tenantId != null) {
        docData['tenant_id'] = tenantId;
      }
    }

    // Adiciona timestamps
    docData['created_at'] = FieldValue.serverTimestamp();
    docData['updated_at'] = FieldValue.serverTimestamp();
    docData['created_by'] = _auth.currentUser?.uid;

    if (id != null) {
      docData['id'] = id;
      await _firestore.collection(collection).doc(id).set(docData);
      return id;
    } else {
      final docRef = await _firestore.collection(collection).add(docData);
      // Atualiza o ID no documento
      await docRef.update({'id': docRef.id});
      return docRef.id;
    }
  }

  /// Atualizar documento
  Future<void> update(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final updates = {
      ...data,
      'updated_at': FieldValue.serverTimestamp(),
    };

    await _firestore.collection(collection).doc(id).update(updates);
  }

  /// Deletar documento
  Future<void> delete(String collection, String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  /// Stream de documentos (realtime)
  Stream<List<Map<String, dynamic>>> streamCollection(
    String collection, {
    bool filterByTenant = true,
    String? orderBy,
    bool descending = true,
  }) {
    return Stream.fromFuture(_buildQuery(collection, filterByTenant, orderBy, descending))
        .asyncExpand((query) => query.snapshots())
        .map((snapshot) => snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  Future<Query<Map<String, dynamic>>> _buildQuery(
    String collection,
    bool filterByTenant,
    String? orderBy,
    bool descending,
  ) async {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    if (filterByTenant && !(await isOwner)) {
      final tenantId = await currentTenantId;
      if (tenantId != null) {
        query = query.where('tenant_id', isEqualTo: tenantId);
      }
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    return query;
  }

  /// Buscar com filtros
  Future<List<Map<String, dynamic>>> search(
    String collection, {
    required String field,
    required dynamic value,
    bool filterByTenant = true,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    if (filterByTenant && !(await isOwner)) {
      final tenantId = await currentTenantId;
      if (tenantId != null) {
        query = query.where('tenant_id', isEqualTo: tenantId);
      }
    }

    query = query.where(field, isEqualTo: value);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// Contar documentos
  Future<int> count(String collection, {bool filterByTenant = true}) async {
    final docs = await getAll(collection, filterByTenant: filterByTenant);
    return docs.length;
  }
}
