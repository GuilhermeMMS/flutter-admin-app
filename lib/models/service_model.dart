// Lead Genius Admin - Modelo de Serviço
// Modelo de dados para serviços.

import 'package:equatable/equatable.dart';

/// Modelo de Serviço
class ServiceModel extends Equatable {
  /// ID único do serviço (UUID)
  final String id;
  
  /// ID do tenant
  final String tenantId;
  
  /// Nome do serviço
  final String name;
  
  /// Descrição do serviço
  final String? description;
  
  /// Preço do serviço
  final double price;
  
  /// Tipo de cobrança (hora, projeto, mensal, anual)
  final String billingType;
  
  /// Duração estimada em horas
  final double? estimatedHours;
  
  /// Categoria do serviço
  final String? category;
  
  /// URL da imagem do serviço
  final String? imageUrl;
  
  /// Se o serviço está ativo
  final bool isActive;
  
  /// ID do usuário que criou
  final String createdBy;
  
  /// Data de criação
  final DateTime createdAt;
  
  /// Data da última atualização
  final DateTime updatedAt;
  
  /// Metadados adicionais
  final Map<String, dynamic>? metadata;

  const ServiceModel({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    required this.price,
    this.billingType = 'projeto',
    this.estimatedHours,
    this.category,
    this.imageUrl,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Cria uma instância a partir de JSON
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      billingType: json['billing_type'] as String? ?? 'projeto',
      estimatedHours: json['estimated_hours'] != null 
          ? (json['estimated_hours'] as num).toDouble() 
          : null,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'description': description,
      'price': price,
      'billing_type': billingType,
      'estimated_hours': estimatedHours,
      'category': category,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Cria uma cópia com campos alterados
  ServiceModel copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? description,
    double? price,
    String? billingType,
    double? estimatedHours,
    String? category,
    String? imageUrl,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      billingType: billingType ?? this.billingType,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Retorna o nome do tipo de cobrança
  String get billingTypeDisplay {
    switch (billingType) {
      case 'hora':
        return 'Por Hora';
      case 'projeto':
        return 'Por Projeto';
      case 'mensal':
        return 'Mensal';
      case 'anual':
        return 'Anual';
      default:
        return billingType;
    }
  }

  @override
  List<Object?> get props => [
    id, tenantId, name, description, price, billingType, estimatedHours,
    category, imageUrl, isActive, createdBy, createdAt, updatedAt, metadata
  ];
  
  @override
  String toString() => 'ServiceModel(id: $id, name: $name, price: $price)';
}
