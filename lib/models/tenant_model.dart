// Lead Genius Admin - Modelo de Tenant
// Modelo de dados para tenants (clientes/organizações).

import 'package:equatable/equatable.dart';

/// Configurações visuais do tenant
class TenantSettings extends Equatable {
  final String? logoUrl;
  final String? primaryColor;
  final String? secondaryColor;
  final String? businessName;
  final String? businessAddress;
  final String? businessPhone;
  final String? businessEmail;
  final String? businessWebsite;
  final Map<String, dynamic>? customFields;

  const TenantSettings({
    this.logoUrl,
    this.primaryColor,
    this.secondaryColor,
    this.businessName,
    this.businessAddress,
    this.businessPhone,
    this.businessEmail,
    this.businessWebsite,
    this.customFields,
  });

  factory TenantSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TenantSettings();
    return TenantSettings(
      logoUrl: json['logo_url'] as String?,
      primaryColor: json['primary_color'] as String?,
      secondaryColor: json['secondary_color'] as String?,
      businessName: json['business_name'] as String?,
      businessAddress: json['business_address'] as String?,
      businessPhone: json['business_phone'] as String?,
      businessEmail: json['business_email'] as String?,
      businessWebsite: json['business_website'] as String?,
      customFields: json['custom_fields'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logo_url': logoUrl,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'business_name': businessName,
      'business_address': businessAddress,
      'business_phone': businessPhone,
      'business_email': businessEmail,
      'business_website': businessWebsite,
      'custom_fields': customFields,
    };
  }

  TenantSettings copyWith({
    String? logoUrl,
    String? primaryColor,
    String? secondaryColor,
    String? businessName,
    String? businessAddress,
    String? businessPhone,
    String? businessEmail,
    String? businessWebsite,
    Map<String, dynamic>? customFields,
  }) {
    return TenantSettings(
      logoUrl: logoUrl ?? this.logoUrl,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      businessPhone: businessPhone ?? this.businessPhone,
      businessEmail: businessEmail ?? this.businessEmail,
      businessWebsite: businessWebsite ?? this.businessWebsite,
      customFields: customFields ?? this.customFields,
    );
  }

  @override
  List<Object?> get props => [
    logoUrl, primaryColor, secondaryColor, businessName,
    businessAddress, businessPhone, businessEmail, businessWebsite, customFields
  ];
}

/// Modelo de tenant (organização/cliente)
class TenantModel extends Equatable {
  /// ID único do tenant (UUID)
  final String id;
  
  /// Nome do tenant
  final String name;
  
  /// Plano do tenant (free, starter, professional, enterprise)
  final String plan;
  
  /// Se o tenant está ativo
  final bool isActive;
  
  /// ID do usuário proprietário
  final String ownerUserId;
  
  /// Configurações visuais e de negócio
  final TenantSettings settings;
  
  /// Número máximo de usuários permitidos
  final int maxUsers;
  
  /// Data de criação
  final DateTime createdAt;
  
  /// Data de expiração do plano
  final DateTime? planExpiresAt;
  
  /// Metadados adicionais
  final Map<String, dynamic>? metadata;

  const TenantModel({
    required this.id,
    required this.name,
    required this.plan,
    this.isActive = true,
    required this.ownerUserId,
    this.settings = const TenantSettings(),
    this.maxUsers = 1,
    required this.createdAt,
    this.planExpiresAt,
    this.metadata,
  });

  /// Cria uma instância a partir de JSON
  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      plan: json['plan'] as String? ?? 'free',
      isActive: json['is_active'] as bool? ?? true,
      ownerUserId: json['owner_user_id'] as String,
      settings: TenantSettings.fromJson(json['settings'] as Map<String, dynamic>?),
      maxUsers: json['max_users'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      planExpiresAt: json['plan_expires_at'] != null 
          ? DateTime.parse(json['plan_expires_at'] as String) 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plan': plan,
      'is_active': isActive,
      'owner_user_id': ownerUserId,
      'settings': settings.toJson(),
      'max_users': maxUsers,
      'created_at': createdAt.toIso8601String(),
      'plan_expires_at': planExpiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Cria uma cópia com campos alterados
  TenantModel copyWith({
    String? id,
    String? name,
    String? plan,
    bool? isActive,
    String? ownerUserId,
    TenantSettings? settings,
    int? maxUsers,
    DateTime? createdAt,
    DateTime? planExpiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return TenantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      plan: plan ?? this.plan,
      isActive: isActive ?? this.isActive,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      settings: settings ?? this.settings,
      maxUsers: maxUsers ?? this.maxUsers,
      createdAt: createdAt ?? this.createdAt,
      planExpiresAt: planExpiresAt ?? this.planExpiresAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Verifica se o plano está expirado
  bool get isPlanExpired {
    if (planExpiresAt == null) return false;
    return DateTime.now().isAfter(planExpiresAt!);
  }
  
  /// Verifica se é plano gratuito
  bool get isFreePlan => plan == 'free';
  
  /// Verifica se é plano enterprise
  bool get isEnterprise => plan == 'enterprise';

  @override
  List<Object?> get props => [
    id, name, plan, isActive, ownerUserId, settings,
    maxUsers, createdAt, planExpiresAt, metadata
  ];
  
  @override
  String toString() => 'TenantModel(id: $id, name: $name, plan: $plan)';
}
