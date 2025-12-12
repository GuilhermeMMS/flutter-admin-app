// Lead Genius Admin - Route Guards (Firebase)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/auth_provider.dart';
import '../../services/auth_service.dart';

// ==========================================
// FUNÇÕES DE VERIFICAÇÃO
// ==========================================

/// Verifica se o usuário está autenticado
bool isAuthenticated(WidgetRef ref) {
  return ref.read(isLoggedInProvider);
}

/// Obtém a role do usuário atual
String? getCurrentUserRole(WidgetRef ref) {
  return ref.read(currentUserRoleProvider);
}

/// Obtém o tenant_id do usuário atual
String? getCurrentTenantId(WidgetRef ref) {
  return ref.read(currentTenantIdProvider);
}

// ==========================================
// REDIRECT GUARDS PARA GO_ROUTER
// ==========================================

/// Guard que requer autenticação
String? requireAuth(BuildContext context, GoRouterState state, WidgetRef ref) {
  if (!isAuthenticated(ref)) {
    return '/login';
  }
  return null;
}

/// Guard que requer uma role específica
String? requireRole(BuildContext context, GoRouterState state, WidgetRef ref, List<String> allowedRoles) {
  if (!isAuthenticated(ref)) {
    return '/login';
  }
  
  final role = getCurrentUserRole(ref);
  if (role == null || !allowedRoles.contains(role)) {
    return '/client/dashboard';
  }
  
  return null;
}

/// Guard que requer role de owner
String? requireOwner(BuildContext context, GoRouterState state, WidgetRef ref) {
  if (!isAuthenticated(ref)) {
    return '/login';
  }
  
  final role = getCurrentUserRole(ref);
  if (role == null || !role.startsWith('owner')) {
    return '/client/dashboard';
  }
  
  return null;
}

/// Guard que requer role de cliente
String? requireClient(BuildContext context, GoRouterState state, WidgetRef ref) {
  if (!isAuthenticated(ref)) {
    return '/login';
  }
  
  final role = getCurrentUserRole(ref);
  if (role == null || !role.startsWith('cliente')) {
    return '/owner/dashboard';
  }
  
  return null;
}

/// Guard que requer permissão de escrita
String? requireWritePermission(BuildContext context, GoRouterState state, WidgetRef ref) {
  if (!isAuthenticated(ref)) {
    return '/login';
  }
  
  final canWrite = ref.read(canWriteProvider);
  if (!canWrite) {
    return null;
  }
  
  return null;
}

// ==========================================
// WIDGET GUARDS
// ==========================================

/// Widget que mostra conteúdo apenas para roles específicas
class RoleGuard extends ConsumerWidget {
  final List<String> allowedRoles;
  final Widget child;
  final Widget? fallback;
  
  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    
    if (role != null && allowedRoles.contains(role)) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

/// Widget que mostra conteúdo apenas para usuários com permissão de escrita
class WritePermissionGuard extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;
  
  const WritePermissionGuard({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canWrite = ref.watch(canWriteProvider);
    
    if (canWrite) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

/// Widget que mostra conteúdo apenas para owners
class OwnerOnly extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;
  
  const OwnerOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner = ref.watch(isOwnerProvider);
    
    if (isOwner) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

/// Widget que mostra conteúdo apenas para clientes
class ClientOnly extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;
  
  const ClientOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final isClient = role?.startsWith('cliente') ?? false;
    
    if (isClient) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}
