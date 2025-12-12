// Lead Genius Admin - Modelo de Contrato
// Modelo de dados para contratos.

import 'package:equatable/equatable.dart';

/// Item do contrato
class ContractItem extends Equatable {
  final String id;
  final String type; // product ou service
  final String itemId;
  final String name;
  final double unitPrice;
  final int quantity;
  final double discount;
  
  const ContractItem({
    required this.id,
    required this.type,
    required this.itemId,
    required this.name,
    required this.unitPrice,
    this.quantity = 1,
    this.discount = 0,
  });

  factory ContractItem.fromJson(Map<String, dynamic> json) {
    return ContractItem(
      id: json['id'] as String,
      type: json['type'] as String,
      itemId: json['item_id'] as String,
      name: json['name'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
      discount: json['discount'] != null 
          ? (json['discount'] as num).toDouble() 
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'item_id': itemId,
      'name': name,
      'unit_price': unitPrice,
      'quantity': quantity,
      'discount': discount,
    };
  }

  double get total => (unitPrice * quantity) - discount;

  @override
  List<Object?> get props => [id, type, itemId, name, unitPrice, quantity, discount];
}

/// Modelo de Contrato
class ContractModel extends Equatable {
  /// ID único do contrato (UUID)
  final String id;
  
  /// ID do tenant
  final String tenantId;
  
  /// Número do contrato
  final String? contractNumber;
  
  /// Nome do cliente
  final String customerName;
  
  /// Email do cliente
  final String? customerEmail;
  
  /// Telefone do cliente
  final String? customerPhone;
  
  /// Documento do cliente (CPF/CNPJ)
  final String? customerDocument;
  
  /// Endereço do cliente
  final String? customerAddress;
  
  /// ID do lead associado
  final String? leadId;
  
  /// Itens do contrato
  final List<ContractItem> items;
  
  /// Valor total do contrato
  final double value;
  
  /// Desconto total
  final double discount;
  
  /// Valor final (value - discount)
  final double finalValue;
  
  /// Número de parcelas
  final int installments;
  
  /// Status do contrato
  final String status;
  
  /// Data de início
  final DateTime startDate;
  
  /// Data de término
  final DateTime? endDate;
  
  /// Observações
  final String? notes;
  
  /// Termos e condições
  final String? terms;
  
  /// URL do PDF gerado
  final String? pdfUrl;
  
  /// Data de assinatura
  final DateTime? signedAt;
  
  /// ID do usuário que criou
  final String createdBy;
  
  /// Data de criação
  final DateTime createdAt;
  
  /// Data da última atualização
  final DateTime updatedAt;
  
  /// Metadados adicionais
  final Map<String, dynamic>? metadata;

  const ContractModel({
    required this.id,
    required this.tenantId,
    this.contractNumber,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.customerDocument,
    this.customerAddress,
    this.leadId,
    this.items = const [],
    required this.value,
    this.discount = 0,
    required this.finalValue,
    this.installments = 1,
    this.status = 'rascunho',
    required this.startDate,
    this.endDate,
    this.notes,
    this.terms,
    this.pdfUrl,
    this.signedAt,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Cria uma instância a partir de JSON
  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      contractNumber: json['contract_number'] as String?,
      customerName: json['customer_name'] as String,
      customerEmail: json['customer_email'] as String?,
      customerPhone: json['customer_phone'] as String?,
      customerDocument: json['customer_document'] as String?,
      customerAddress: json['customer_address'] as String?,
      leadId: json['lead_id'] as String?,
      items: json['items'] != null
          ? (json['items'] as List).map((e) => ContractItem.fromJson(e)).toList()
          : const [],
      value: (json['value'] as num).toDouble(),
      discount: json['discount'] != null 
          ? (json['discount'] as num).toDouble() 
          : 0,
      finalValue: (json['final_value'] as num).toDouble(),
      installments: json['installments'] as int? ?? 1,
      status: json['status'] as String? ?? 'rascunho',
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date'] as String) 
          : null,
      notes: json['notes'] as String?,
      terms: json['terms'] as String?,
      pdfUrl: json['pdf_url'] as String?,
      signedAt: json['signed_at'] != null 
          ? DateTime.parse(json['signed_at'] as String) 
          : null,
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
      'contract_number': contractNumber,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'customer_document': customerDocument,
      'customer_address': customerAddress,
      'lead_id': leadId,
      'items': items.map((e) => e.toJson()).toList(),
      'value': value,
      'discount': discount,
      'final_value': finalValue,
      'installments': installments,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'notes': notes,
      'terms': terms,
      'pdf_url': pdfUrl,
      'signed_at': signedAt?.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Cria uma cópia com campos alterados
  ContractModel copyWith({
    String? id,
    String? tenantId,
    String? contractNumber,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerDocument,
    String? customerAddress,
    String? leadId,
    List<ContractItem>? items,
    double? value,
    double? discount,
    double? finalValue,
    int? installments,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? terms,
    String? pdfUrl,
    DateTime? signedAt,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ContractModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      contractNumber: contractNumber ?? this.contractNumber,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerDocument: customerDocument ?? this.customerDocument,
      customerAddress: customerAddress ?? this.customerAddress,
      leadId: leadId ?? this.leadId,
      items: items ?? this.items,
      value: value ?? this.value,
      discount: discount ?? this.discount,
      finalValue: finalValue ?? this.finalValue,
      installments: installments ?? this.installments,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      signedAt: signedAt ?? this.signedAt,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Verifica se está assinado
  bool get isSigned => signedAt != null;
  
  /// Verifica se está ativo
  bool get isActive => status == 'ativo';
  
  /// Valor da parcela
  double get installmentValue => finalValue / installments;
  
  /// Dias restantes
  int? get daysRemaining {
    if (endDate == null) return null;
    return endDate!.difference(DateTime.now()).inDays;
  }

  @override
  List<Object?> get props => [
    id, tenantId, contractNumber, customerName, customerEmail, customerPhone,
    customerDocument, customerAddress, leadId, items, value, discount, finalValue,
    installments, status, startDate, endDate, notes, terms, pdfUrl, signedAt,
    createdBy, createdAt, updatedAt, metadata
  ];
  
  @override
  String toString() => 'ContractModel(id: $id, customerName: $customerName, value: $value)';
}
