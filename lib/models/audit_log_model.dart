// Lead Genius Admin - Modelo de Log de Auditoria
// Modelo de dados para logs de auditoria.

import 'package:equatable/equatable.dart';

/// Modelo de Log de Auditoria
class AuditLogModel extends Equatable {
  /// ID único do log (UUID)
  final String id;
  
  /// ID do usuário que executou a ação
  final String userId;
  
  /// Nome do usuário (para exibição)
  final String? userName;
  
  /// ID do tenant (null para ações de owner)
  final String? tenantId;
  
  /// Tipo de ação (create, update, delete, login, logout, export, import)
  final String action;
  
  /// Modelo afetado (users, leads, products, contracts, etc.)
  final String model;
  
  /// ID do registro afetado
  final String? modelId;
  
  /// Valor anterior (JSON string)
  final Map<String, dynamic>? oldValue;
  
  /// Novo valor (JSON string)
  final Map<String, dynamic>? newValue;
  
  /// Descrição da ação
  final String? description;
  
  /// IP do usuário
  final String? ipAddress;
  
  /// User Agent do navegador
  final String? userAgent;
  
  /// Timestamp da ação
  final DateTime timestamp;
  
  /// Metadados adicionais
  final Map<String, dynamic>? metadata;

  const AuditLogModel({
    required this.id,
    required this.userId,
    this.userName,
    this.tenantId,
    required this.action,
    required this.model,
    this.modelId,
    this.oldValue,
    this.newValue,
    this.description,
    this.ipAddress,
    this.userAgent,
    required this.timestamp,
    this.metadata,
  });

  /// Cria uma instância a partir de JSON
  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String?,
      tenantId: json['tenant_id'] as String?,
      action: json['action'] as String,
      model: json['model'] as String,
      modelId: json['model_id'] as String?,
      oldValue: json['old_value'] as Map<String, dynamic>?,
      newValue: json['new_value'] as Map<String, dynamic>?,
      description: json['description'] as String?,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'tenant_id': tenantId,
      'action': action,
      'model': model,
      'model_id': modelId,
      'old_value': oldValue,
      'new_value': newValue,
      'description': description,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Retorna o nome amigável da ação
  String get actionDisplay {
    switch (action) {
      case 'create':
        return 'Criação';
      case 'update':
        return 'Atualização';
      case 'delete':
        return 'Exclusão';
      case 'login':
        return 'Login';
      case 'logout':
        return 'Logout';
      case 'export':
        return 'Exportação';
      case 'import':
        return 'Importação';
      default:
        return action;
    }
  }
  
  /// Retorna o nome amigável do modelo
  String get modelDisplay {
    switch (model) {
      case 'users':
        return 'Usuários';
      case 'tenants':
        return 'Tenants';
      case 'leads':
        return 'Leads';
      case 'products':
        return 'Produtos';
      case 'services':
        return 'Serviços';
      case 'contracts':
        return 'Contratos';
      case 'invoices':
        return 'Faturas';
      default:
        return model;
    }
  }

  @override
  List<Object?> get props => [
    id, userId, userName, tenantId, action, model, modelId,
    oldValue, newValue, description, ipAddress, userAgent, timestamp, metadata
  ];
  
  @override
  String toString() => 'AuditLogModel(id: $id, action: $action, model: $model)';
}
