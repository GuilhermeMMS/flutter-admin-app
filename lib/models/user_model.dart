// Lead Genius Admin - Modelo de Usuário
// Modelo de dados para usuários do sistema.

import 'package:equatable/equatable.dart';

/// Modelo de usuário do sistema
class UserModel extends Equatable {
  /// ID único do usuário (UUID)
  final String id;
  
  /// Email do usuário
  final String email;
  
  /// Nome completo do usuário
  final String name;
  
  /// Role do usuário (owner_admin, owner_viewer, cliente_admin, cliente_user)
  final String role;
  
  /// ID do tenant (null para owners)
  final String? tenantId;
  
  /// URL do avatar do usuário
  final String? avatarUrl;
  
  /// Telefone do usuário
  final String? phone;
  
  /// Se o usuário está ativo
  final bool isActive;
  
  /// Data de criação
  final DateTime createdAt;
  
  /// Data do último login
  final DateTime? lastLogin;
  
  /// Metadados adicionais
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.tenantId,
    this.avatarUrl,
    this.phone,
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
    this.metadata,
  });

  /// Cria uma instância a partir de JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? 'Sem nome',
      role: json['role'] as String? ?? 'cliente_user',
      tenantId: json['tenant_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login'] as String) 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'tenant_id': tenantId,
      'avatar_url': avatarUrl,
      'phone': phone,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Cria uma cópia com campos alterados
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? tenantId,
    String? avatarUrl,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      tenantId: tenantId ?? this.tenantId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Verifica se o usuário é owner
  bool get isOwner => role.startsWith('owner');
  
  /// Verifica se o usuário é cliente
  bool get isClient => role.startsWith('cliente');
  
  /// Verifica se o usuário tem permissão de escrita
  bool get canWrite => role == 'owner_admin' || role == 'cliente_admin';

  @override
  List<Object?> get props => [
    id, email, name, role, tenantId, avatarUrl, phone, 
    isActive, createdAt, lastLogin, metadata
  ];
  
  @override
  String toString() => 'UserModel(id: $id, email: $email, name: $name, role: $role)';
}
