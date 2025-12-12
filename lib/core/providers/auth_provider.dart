// Lead Genius Admin - Provider de Autenticação (Firebase)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../models/user_model.dart';

/// Stream de estado de autenticação do Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Provider do usuário Firebase atual
final currentFirebaseUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Provider dos dados do usuário (do Firestore)
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final firebaseUser = ref.watch(currentFirebaseUserProvider);
  if (firebaseUser == null) return null;

  final firestore = ref.read(firestoreProvider);
  final doc = await firestore.collection('users').doc(firebaseUser.uid).get();
  
  if (!doc.exists) return null;
  return UserModel.fromJson({'id': doc.id, ...doc.data()!});
});

/// Provider da role do usuário atual
final currentUserRoleProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider).valueOrNull?.role;
});

/// Provider do tenant_id do usuário atual
final currentTenantIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider).valueOrNull?.tenantId;
});

/// Provider para verificar se está logado
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentFirebaseUserProvider) != null;
});

/// Provider para verificar se é owner
final isOwnerProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role?.startsWith('owner') ?? false;
});

/// Provider para verificar se é cliente admin
final isClientAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == 'cliente_admin';
});

/// Provider para verificar se pode escrever
final canWriteProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == 'owner_admin' || role == 'cliente_admin';
});
