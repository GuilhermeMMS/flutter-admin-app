// Lead Genius Admin - Configuração de Rotas (Firebase)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/auth_provider.dart';

// Páginas de Autenticação
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/auth/forgot_password_page.dart';

// Páginas de Cliente
import '../pages/client/client_dashboard_page.dart';
import '../pages/client/client_shell_wrapper.dart';
import '../pages/client/leads/lead_list_page.dart';
import '../pages/client/leads/lead_detail_page.dart';
import '../pages/client/leads/lead_form_page.dart';
import '../pages/client/products/product_list_page.dart';
import '../pages/client/products/product_form_page.dart';
import '../pages/client/services/service_list_page.dart';
import '../pages/client/services/service_form_page.dart';
import '../pages/client/contracts/contract_list_page.dart';
import '../pages/client/contracts/contract_detail_page.dart';
import '../pages/client/contracts/contract_form_page.dart';
import '../pages/client/reports/reports_page.dart';
import '../pages/client/settings/client_settings_page.dart';
import '../pages/client/settings/user_management_page.dart';

// Páginas de Owner/Super-Admin
import '../pages/owner/owner_dashboard_page.dart';
import '../pages/owner/owner_shell_wrapper.dart';
import '../pages/owner/tenants/tenant_list_page.dart';
import '../pages/owner/tenants/tenant_detail_page.dart';
import '../pages/owner/tenants/tenant_form_page.dart';
import '../pages/owner/users/global_user_management_page.dart';
import '../pages/owner/audit/audit_logs_page.dart';
import '../pages/owner/support/support_tools_page.dart';
import '../pages/owner/billing/billing_page.dart';

/// Chave global para navegação
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provider do router
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    
    // Redirecionamento baseado em autenticação e role
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
                          state.matchedLocation == '/register' ||
                          state.matchedLocation == '/forgot-password';
      
      // Se não está logado e não está em rota de auth, redireciona para login
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      
      // Se está logado e está em rota de auth, redireciona baseado na role
      if (isLoggedIn && isAuthRoute) {
        final role = ref.read(currentUserRoleProvider);
        
        if (role?.startsWith('owner') == true) {
          return '/owner/dashboard';
        } else {
          return '/client/dashboard';
        }
      }
      
      return null; // Sem redirecionamento
    },
    
    routes: [
      // ==========================================
      // ROTAS DE AUTENTICAÇÃO
      // ==========================================
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      // ==========================================
      // ROTAS DE CLIENTE (TENANT ADMIN)
      // ==========================================
      ShellRoute(
        builder: (context, state, child) {
          return ClientShellWrapper(child: child);
        },
        routes: [
          GoRoute(
            path: '/client/dashboard',
            name: 'client-dashboard',
            builder: (context, state) => const ClientDashboardPage(),
          ),
          
          // Leads
          GoRoute(
            path: '/client/leads',
            name: 'client-leads',
            builder: (context, state) => const LeadListPage(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'client-lead-new',
                builder: (context, state) => const LeadFormPage(),
              ),
              GoRoute(
                path: ':id',
                name: 'client-lead-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return LeadDetailPage(leadId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'client-lead-edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return LeadFormPage(leadId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Produtos
          GoRoute(
            path: '/client/products',
            name: 'client-products',
            builder: (context, state) => const ProductListPage(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'client-product-new',
                builder: (context, state) => const ProductFormPage(),
              ),
              GoRoute(
                path: ':id/edit',
                name: 'client-product-edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ProductFormPage(productId: id);
                },
              ),
            ],
          ),
          
          // Serviços
          GoRoute(
            path: '/client/services',
            name: 'client-services',
            builder: (context, state) => const ServiceListPage(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'client-service-new',
                builder: (context, state) => const ServiceFormPage(),
              ),
              GoRoute(
                path: ':id/edit',
                name: 'client-service-edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ServiceFormPage(serviceId: id);
                },
              ),
            ],
          ),
          
          // Contratos
          GoRoute(
            path: '/client/contracts',
            name: 'client-contracts',
            builder: (context, state) => const ContractListPage(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'client-contract-new',
                builder: (context, state) => const ContractFormPage(),
              ),
              GoRoute(
                path: ':id',
                name: 'client-contract-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ContractDetailPage(contractId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'client-contract-edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ContractFormPage(contractId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Relatórios
          GoRoute(
            path: '/client/reports',
            name: 'client-reports',
            builder: (context, state) => const ReportsPage(),
          ),
          
          // Configurações
          GoRoute(
            path: '/client/settings',
            name: 'client-settings',
            builder: (context, state) => const ClientSettingsPage(),
          ),
          GoRoute(
            path: '/client/users',
            name: 'client-users',
            builder: (context, state) => const UserManagementPage(),
          ),
        ],
      ),
      
      // ==========================================
      // ROTAS DE OWNER (SUPER-ADMIN)
      // ==========================================
      ShellRoute(
        builder: (context, state, child) {
          return OwnerShellWrapper(child: child);
        },
        routes: [
          GoRoute(
            path: '/owner/dashboard',
            name: 'owner-dashboard',
            builder: (context, state) => const OwnerDashboardPage(),
          ),
          
          // Tenants
          GoRoute(
            path: '/owner/tenants',
            name: 'owner-tenants',
            builder: (context, state) => const TenantListPage(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'owner-tenant-new',
                builder: (context, state) => const TenantFormPage(),
              ),
              GoRoute(
                path: ':id',
                name: 'owner-tenant-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TenantDetailPage(tenantId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'owner-tenant-edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return TenantFormPage(tenantId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Usuários Globais
          GoRoute(
            path: '/owner/users',
            name: 'owner-users',
            builder: (context, state) => const GlobalUserManagementPage(),
          ),
          
          // Auditoria
          GoRoute(
            path: '/owner/audit',
            name: 'owner-audit',
            builder: (context, state) => const AuditLogsPage(),
          ),
          
          // Suporte
          GoRoute(
            path: '/owner/support',
            name: 'owner-support',
            builder: (context, state) => const SupportToolsPage(),
          ),
          
          // Faturamento
          GoRoute(
            path: '/owner/billing',
            name: 'owner-billing',
            builder: (context, state) => const BillingPage(),
          ),
        ],
      ),
    ],
    
    // Página de erro
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página não encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.error?.message ?? 'Erro desconhecido'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    ),
  );
});
