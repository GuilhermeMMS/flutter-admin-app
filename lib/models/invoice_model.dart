// Lead Genius Admin - Modelo de Invoice
// Modelo de dados para faturas.

import 'package:equatable/equatable.dart';

/// Item da fatura
class InvoiceItem extends Equatable {
  final String id;
  final String description;
  final double unitPrice;
  final int quantity;
  final double total;

  const InvoiceItem({
    required this.id,
    required this.description,
    required this.unitPrice,
    this.quantity = 1,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] as String,
      description: json['description'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total': total,
    };
  }

  @override
  List<Object?> get props => [id, description, unitPrice, quantity, total];
}

/// Modelo de Invoice (Fatura)
class InvoiceModel extends Equatable {
  /// ID único da fatura (UUID)
  final String id;
  
  /// ID do tenant
  final String tenantId;
  
  /// Número da fatura
  final String invoiceNumber;
  
  /// Período de referência (início)
  final DateTime periodStart;
  
  /// Período de referência (fim)
  final DateTime periodEnd;
  
  /// Itens da fatura
  final List<InvoiceItem> items;
  
  /// Subtotal
  final double subtotal;
  
  /// Impostos
  final double taxes;
  
  /// Descontos
  final double discount;
  
  /// Valor total
  final double total;
  
  /// Status da fatura (draft, sent, paid, overdue, cancelled)
  final String status;
  
  /// Data de vencimento
  final DateTime dueDate;
  
  /// Data de pagamento
  final DateTime? paidAt;
  
  /// Método de pagamento
  final String? paymentMethod;
  
  /// ID da transação de pagamento
  final String? paymentTransactionId;
  
  /// URL do PDF
  final String? pdfUrl;
  
  /// Notas
  final String? notes;
  
  /// Data de criação
  final DateTime createdAt;
  
  /// Data da última atualização
  final DateTime updatedAt;
  
  /// Metadados adicionais
  final Map<String, dynamic>? metadata;

  const InvoiceModel({
    required this.id,
    required this.tenantId,
    required this.invoiceNumber,
    required this.periodStart,
    required this.periodEnd,
    this.items = const [],
    required this.subtotal,
    this.taxes = 0,
    this.discount = 0,
    required this.total,
    this.status = 'draft',
    required this.dueDate,
    this.paidAt,
    this.paymentMethod,
    this.paymentTransactionId,
    this.pdfUrl,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Cria uma instância a partir de JSON
  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      items: json['items'] != null
          ? (json['items'] as List).map((e) => InvoiceItem.fromJson(e)).toList()
          : const [],
      subtotal: (json['subtotal'] as num).toDouble(),
      taxes: json['taxes'] != null 
          ? (json['taxes'] as num).toDouble() 
          : 0,
      discount: json['discount'] != null 
          ? (json['discount'] as num).toDouble() 
          : 0,
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String? ?? 'draft',
      dueDate: DateTime.parse(json['due_date'] as String),
      paidAt: json['paid_at'] != null 
          ? DateTime.parse(json['paid_at'] as String) 
          : null,
      paymentMethod: json['payment_method'] as String?,
      paymentTransactionId: json['payment_transaction_id'] as String?,
      pdfUrl: json['pdf_url'] as String?,
      notes: json['notes'] as String?,
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
      'invoice_number': invoiceNumber,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'taxes': taxes,
      'discount': discount,
      'total': total,
      'status': status,
      'due_date': dueDate.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'payment_method': paymentMethod,
      'payment_transaction_id': paymentTransactionId,
      'pdf_url': pdfUrl,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Cria uma cópia com campos alterados
  InvoiceModel copyWith({
    String? id,
    String? tenantId,
    String? invoiceNumber,
    DateTime? periodStart,
    DateTime? periodEnd,
    List<InvoiceItem>? items,
    double? subtotal,
    double? taxes,
    double? discount,
    double? total,
    String? status,
    DateTime? dueDate,
    DateTime? paidAt,
    String? paymentMethod,
    String? paymentTransactionId,
    String? pdfUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxes: taxes ?? this.taxes,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Verifica se está pago
  bool get isPaid => status == 'paid';
  
  /// Verifica se está vencido
  bool get isOverdue => status == 'overdue' || 
      (status != 'paid' && DateTime.now().isAfter(dueDate));
  
  /// Dias até vencimento (negativo se já venceu)
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
  
  /// Retorna o nome do status
  String get statusDisplay {
    switch (status) {
      case 'draft':
        return 'Rascunho';
      case 'sent':
        return 'Enviada';
      case 'paid':
        return 'Paga';
      case 'overdue':
        return 'Vencida';
      case 'cancelled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  @override
  List<Object?> get props => [
    id, tenantId, invoiceNumber, periodStart, periodEnd, items,
    subtotal, taxes, discount, total, status, dueDate, paidAt,
    paymentMethod, paymentTransactionId, pdfUrl, notes, createdAt, updatedAt, metadata
  ];
  
  @override
  String toString() => 'InvoiceModel(id: $id, number: $invoiceNumber, total: $total)';
}
