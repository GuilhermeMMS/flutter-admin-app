// Lead Genius Admin - Constantes do Aplicativo
// Constantes globais utilizadas em todo o app.

/// Constantes de armazenamento
class StorageKeys {
  StorageKeys._();
  
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String tenantId = 'tenant_id';
  static const String userRole = 'user_role';
  static const String themeMode = 'theme_mode';
  static const String lastLogin = 'last_login';
}

/// Roles de usuário
class UserRoles {
  UserRoles._();
  
  // Roles de Owner (Super-Admin)
  static const String ownerAdmin = 'owner_admin';
  static const String ownerViewer = 'owner_viewer';
  
  // Roles de Cliente (Tenant)
  static const String clienteAdmin = 'cliente_admin';
  static const String clienteUser = 'cliente_user';
  
  /// Verifica se a role é de owner
  static bool isOwner(String role) {
    return role == ownerAdmin || role == ownerViewer;
  }
  
  /// Verifica se a role é de cliente
  static bool isClient(String role) {
    return role == clienteAdmin || role == clienteUser;
  }
  
  /// Verifica se a role tem permissão de escrita
  static bool canWrite(String role) {
    return role == ownerAdmin || role == clienteAdmin;
  }
  
  /// Retorna o nome amigável da role
  static String displayName(String role) {
    switch (role) {
      case ownerAdmin:
        return 'Super Administrador';
      case ownerViewer:
        return 'Visualizador Global';
      case clienteAdmin:
        return 'Administrador';
      case clienteUser:
        return 'Usuário';
      default:
        return 'Desconhecido';
    }
  }
}

/// Status de Lead
class LeadStatus {
  LeadStatus._();
  
  static const String novo = 'novo';
  static const String contatado = 'contatado';
  static const String qualificado = 'qualificado';
  static const String proposta = 'proposta';
  static const String negociacao = 'negociacao';
  static const String ganho = 'ganho';
  static const String perdido = 'perdido';
  
  static List<String> all = [
    novo,
    contatado,
    qualificado,
    proposta,
    negociacao,
    ganho,
    perdido,
  ];
  
  static String displayName(String status) {
    switch (status) {
      case novo:
        return 'Novo';
      case contatado:
        return 'Contatado';
      case qualificado:
        return 'Qualificado';
      case proposta:
        return 'Proposta';
      case negociacao:
        return 'Negociação';
      case ganho:
        return 'Ganho';
      case perdido:
        return 'Perdido';
      default:
        return status;
    }
  }
}

/// Status de Contrato
class ContractStatus {
  ContractStatus._();
  
  static const String rascunho = 'rascunho';
  static const String enviado = 'enviado';
  static const String assinado = 'assinado';
  static const String ativo = 'ativo';
  static const String finalizado = 'finalizado';
  static const String cancelado = 'cancelado';
  
  static List<String> all = [
    rascunho,
    enviado,
    assinado,
    ativo,
    finalizado,
    cancelado,
  ];
  
  static String displayName(String status) {
    switch (status) {
      case rascunho:
        return 'Rascunho';
      case enviado:
        return 'Enviado';
      case assinado:
        return 'Assinado';
      case ativo:
        return 'Ativo';
      case finalizado:
        return 'Finalizado';
      case cancelado:
        return 'Cancelado';
      default:
        return status;
    }
  }
}

/// Planos de Tenant
class TenantPlans {
  TenantPlans._();
  
  static const String free = 'free';
  static const String starter = 'starter';
  static const String professional = 'professional';
  static const String enterprise = 'enterprise';
  
  static List<String> all = [free, starter, professional, enterprise];
  
  static String displayName(String plan) {
    switch (plan) {
      case free:
        return 'Gratuito';
      case starter:
        return 'Iniciante';
      case professional:
        return 'Profissional';
      case enterprise:
        return 'Empresarial';
      default:
        return plan;
    }
  }
  
  static int maxUsers(String plan) {
    switch (plan) {
      case free:
        return 1;
      case starter:
        return 5;
      case professional:
        return 20;
      case enterprise:
        return -1; // Ilimitado
      default:
        return 1;
    }
  }
}

/// Tipos de ação para auditoria
class AuditActions {
  AuditActions._();
  
  static const String create = 'create';
  static const String update = 'update';
  static const String delete = 'delete';
  static const String login = 'login';
  static const String logout = 'logout';
  static const String export = 'export';
  static const String import = 'import';
  
  static String displayName(String action) {
    switch (action) {
      case create:
        return 'Criação';
      case update:
        return 'Atualização';
      case delete:
        return 'Exclusão';
      case login:
        return 'Login';
      case logout:
        return 'Logout';
      case export:
        return 'Exportação';
      case import:
        return 'Importação';
      default:
        return action;
    }
  }
}

/// Mensagens padrão
class AppMessages {
  AppMessages._();
  
  // Sucesso
  static const String savedSuccess = 'Salvo com sucesso!';
  static const String deletedSuccess = 'Excluído com sucesso!';
  static const String updatedSuccess = 'Atualizado com sucesso!';
  static const String loginSuccess = 'Login realizado com sucesso!';
  static const String logoutSuccess = 'Logout realizado com sucesso!';
  
  // Erro
  static const String genericError = 'Ocorreu um erro. Tente novamente.';
  static const String networkError = 'Erro de conexão. Verifique sua internet.';
  static const String authError = 'Credenciais inválidas.';
  static const String permissionError = 'Você não tem permissão para esta ação.';
  static const String notFoundError = 'Registro não encontrado.';
  
  // Validação
  static const String requiredField = 'Este campo é obrigatório';
  static const String invalidEmail = 'Email inválido';
  static const String invalidPhone = 'Telefone inválido';
  static const String weakPassword = 'Senha muito fraca (mínimo 6 caracteres)';
  
  // Confirmação
  static const String confirmDelete = 'Tem certeza que deseja excluir?';
  static const String confirmLogout = 'Tem certeza que deseja sair?';
  static const String confirmCancel = 'Tem certeza que deseja cancelar?';
}

/// Duração de animações
class AppDurations {
  AppDurations._();
  
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

/// Espaçamentos padrão
class AppSpacing {
  AppSpacing._();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Raios de borda padrão
class AppRadius {
  AppRadius._();
  
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double round = 999.0;
}
