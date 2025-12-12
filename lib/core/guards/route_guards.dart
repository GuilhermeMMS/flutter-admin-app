// Lead Genius Admin - Guards de Rota
// Implementa guardas de rota para autenticação e autorização.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart';

/// Verifica se o usuário está autenticado
bool isAuthenticated() {
  return supabase.auth.currentSession != null;
}

/// Obtém a role do usuário atual
String getCurrentUserRole() {
  final user = supabase.auth.currentUser;
  if (user == null) return '';
  return user.userMetadata?['role'] ?? '';
}

/// Obtém o tenant_id do usuário atual
String? getCurrentTenantId() {
  final user = supabase.auth.currentUser;
  if (user == null) return null;
  return user.userMetadata?['tenant_id'];
}

/// Guard que requer autenticação
/// Redireciona para /login se não autenticado
String? requireAuth(BuildContext context, GoRouterState state) {
  if (!isAuthenticated()) {
    return '/login';
  }
  return null;
}

/// Guard que requer roles específicas
/// Uso: requireRole(['owner_admin', 'owner_viewer'])
String? Function(BuildContext, GoRouterState) requireRole(List<String> allowedRoles) {
  return (context, state) {
    if (!isAuthenticated()) {
      return '/login';
    }
    
    final currentRole = getCurrentUserRole();
    
    if (!allowedRoles.contains(currentRole)) {
      // Redireciona para dashboard apropriado
      if (currentRole.startsWith('owner')) {
        return '/owner/dashboard';
      } else {
        return '/client/dashboard';
      }
    }
    
    return null;
  };
}

/// Guard que requer role de Owner
String? requireOwner(BuildContext context, GoRouterState state) {
  if (!isAuthenticated()) {
    return '/login';
  }
  
  final currentRole = getCurrentUserRole();
  
  if (!currentRole.startsWith('owner')) {
    return '/client/dashboard';
  }
  
  return null;
}

/// Guard que requer role de Cliente
String? requireClient(BuildContext context, GoRouterState state) {
  if (!isAuthenticated()) {
    return '/login';
  }
  
  final currentRole = getCurrentUserRole();
  
  if (!currentRole.startsWith('cliente')) {
    return '/owner/dashboard';
  }
  
  return null;
}

/// Guard que requer permissão de escrita (admin roles)
String? requireWritePermission(BuildContext context, GoRouterState state) {
  if (!isAuthenticated()) {
    return '/login';
  }
  
  final currentRole = getCurrentUserRole();
  
  if (currentRole != 'owner_admin' && currentRole != 'cliente_admin') {
    // Usuário apenas visualizador - mostra snackbar e redireciona
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Você não tem permissão para esta ação'),
        backgroundColor: Colors.red,
      ),
    );
    
    if (currentRole.startsWith('owner')) {
      return '/owner/dashboard';
    } else {
      return '/client/dashboard';
    }
  }
  
  return null;
}

/// Widget wrapper para verificar role em tempo real
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
    final currentRole = getCurrentUserRole();
    
    if (allowedRoles.contains(currentRole)) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

/// Widget wrapper para verificar permissão de escrita
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
    final currentRole = getCurrentUserRole();
    final canWrite = currentRole == 'owner_admin' || currentRole == 'cliente_admin';
    
    if (canWrite) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

/// Widget que mostra conteúdo apenas para owners
class OwnerOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const OwnerOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final currentRole = getCurrentUserRole();
    
    if (currentRole.startsWith('owner')) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

/// Widget que mostra conteúdo apenas para clientes
class ClientOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const ClientOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final currentRole = getCurrentUserRole();
    
    if (currentRole.startsWith('cliente')) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}
