// Lead Genius Admin - Modelo de Lead
// Modelo de dados para leads de vendas.

import 'package:equatable/equatable.dart';

/// Histórico de evento do lead
class LeadEvent extends Equatable {
  final String id;
  final String type; // status_change, note, call, email, meeting
  final String description;
  final String? oldValue;
  final String? newValue;
  final String createdBy;
  final DateTime createdAt;

  const LeadEvent({
    required this.id,
    required this.type,
    required this.description,
    this.oldValue,
    this.newValue,
    required this.createdBy,
    required this.createdAt,
  });

  factory LeadEvent.fromJson(Map<String, dynamic> json) {
    return LeadEvent(
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      oldValue: json['old_value'] as String?,
      newValue: json['new_value'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'old_value': oldValue,
      'new_value': newValue,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, type, description, oldValue, newValue, createdBy, createdAt];
}

/// Modelo de Lead
class LeadModel extends Equatable {
  /// ID único do lead (UUID)
  final String id;
  
  /// ID do tenant
  final String tenantId;
  
  /// Nome do lead/contato
  final String name;
  
  /// Email do lead
  final String? email;
  
  /// Telefone do lead
  final String? phone;
  
  /// Empresa do lead
  final String? company;
  
  /// Cargo do lead
  final String? position;
  
  /// Origem do lead (site, indicação, anúncio, etc.)
  final String? source;
  
  /// Status do lead (novo, contatado, qualificado, proposta, negociacao, ganho, perdido)
  final String status;
  
  /// Valor estimado do lead
  final double? estimatedValue;
  
  /// Notas/observações
  final String? notes;
  
  /// Tags do lead
  final List<String> tags;
  
  /// Histórico de eventos
  final List<LeadEvent> history;
  
  /// ID do usuário responsável
  final String ownerUserId;
  
  /// Data de criação
  final DateTime createdAt;
  
  /// Data da última atualização
  final DateTime updatedAt;
  
  /// Data prevista de fechamento
  final DateTime? expectedCloseDate;
  
  /// Metadados adicionais
  final Map<String, dynamic>? metadata;

  const LeadModel({
    required this.id,
    required this.tenantId,
    required this.name,
    this.email,
    this.phone,
    this.company,
    this.position,
    this.source,
    this.status = 'novo',
    this.estimatedValue,
    this.notes,
    this.tags = const [],
    this.history = const [],
    required this.ownerUserId,
    required this.createdAt,
    required this.updatedAt,
    this.expectedCloseDate,
    this.metadata,
  });

  /// Cria uma instância a partir de JSON
  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      position: json['position'] as String?,
      source: json['source'] as String?,
      status: json['status'] as String? ?? 'novo',
      estimatedValue: json['estimated_value'] != null 
          ? (json['estimated_value'] as num).toDouble() 
          : null,
      notes: json['notes'] as String?,
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'] as List) 
          : const [],
      history: json['history'] != null
          ? (json['history'] as List).map((e) => LeadEvent.fromJson(e)).toList()
          : const [],
      ownerUserId: json['owner_user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      expectedCloseDate: json['expected_close_date'] != null 
          ? DateTime.parse(json['expected_close_date'] as String) 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'position': position,
      'source': source,
      'status': status,
      'estimated_value': estimatedValue,
      'notes': notes,
      'tags': tags,
      'history': history.map((e) => e.toJson()).toList(),
      'owner_user_id': ownerUserId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'expected_close_date': expectedCloseDate?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Cria uma cópia com campos alterados
  LeadModel copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? email,
    String? phone,
    String? company,
    String? position,
    String? source,
    String? status,
    double? estimatedValue,
    String? notes,
    List<String>? tags,
    List<LeadEvent>? history,
    String? ownerUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expectedCloseDate,
    Map<String, dynamic>? metadata,
  }) {
    return LeadModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      position: position ?? this.position,
      source: source ?? this.source,
      status: status ?? this.status,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      history: history ?? this.history,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expectedCloseDate: expectedCloseDate ?? this.expectedCloseDate,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Verifica se o lead foi ganho
  bool get isWon => status == 'ganho';
  
  /// Verifica se o lead foi perdido
  bool get isLost => status == 'perdido';
  
  /// Verifica se o lead está ativo (não ganho nem perdido)
  bool get isActive => !isWon && !isLost;
  
  /// Retorna as iniciais do nome para avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  List<Object?> get props => [
    id, tenantId, name, email, phone, company, position, source,
    status, estimatedValue, notes, tags, history, ownerUserId,
    createdAt, updatedAt, expectedCloseDate, metadata
  ];
  
  @override
  String toString() => 'LeadModel(id: $id, name: $name, status: $status)';
}
