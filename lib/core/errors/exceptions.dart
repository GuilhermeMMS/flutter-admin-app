// Lead Genius Admin - Exceções Customizadas
// Exceções personalizadas para tratamento de erros.

/// Exceção base do aplicativo
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exceção de autenticação
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exceção de permissão
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code = 'PERMISSION_DENIED',
    super.originalError,
  });
}

/// Exceção de rede
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code = 'NETWORK_ERROR',
    super.originalError,
  });
}

/// Exceção de validação
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.originalError,
    this.fieldErrors,
  });
}

/// Exceção de não encontrado
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code = 'NOT_FOUND',
    super.originalError,
  });
}

/// Exceção de conflito
class ConflictException extends AppException {
  const ConflictException({
    required super.message,
    super.code = 'CONFLICT',
    super.originalError,
  });
}

/// Exceção de tenant
class TenantException extends AppException {
  const TenantException({
    required super.message,
    super.code = 'TENANT_ERROR',
    super.originalError,
  });
}

/// Exceção de servidor
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code = 'SERVER_ERROR',
    super.originalError,
  });
}

/// Handler para converter exceções do Supabase
AppException handleSupabaseError(dynamic error) {
  if (error.toString().contains('Invalid login credentials')) {
    return const AuthException(
      message: 'Credenciais inválidas. Verifique seu email e senha.',
      code: 'INVALID_CREDENTIALS',
    );
  }
  
  if (error.toString().contains('Email not confirmed')) {
    return const AuthException(
      message: 'Email não confirmado. Verifique sua caixa de entrada.',
      code: 'EMAIL_NOT_CONFIRMED',
    );
  }
  
  if (error.toString().contains('User already registered')) {
    return const ConflictException(
      message: 'Este email já está cadastrado.',
      code: 'USER_EXISTS',
    );
  }
  
  if (error.toString().contains('Row level security')) {
    return const PermissionException(
      message: 'Você não tem permissão para acessar este recurso.',
    );
  }
  
  if (error.toString().contains('network')) {
    return const NetworkException(
      message: 'Erro de conexão. Verifique sua internet.',
    );
  }
  
  return AppException(
    message: 'Ocorreu um erro inesperado. Tente novamente.',
    originalError: error,
  );
}
