// Lead Genius Admin - Modelo de Produto
// Modelo de dados para produtos.

import 'package:equatable/equatable.dart';

/// Modelo de Produto
class ProductModel extends Equatable {
  /// ID único do produto (UUID)
  final String id;
  
  /// ID do tenant
  final String tenantId;
  
  /// Nome do produto
  final String name;
  
  /// Descrição do produto
  final String? description;
  
  /// Preço do produto
  final double price;
  
  /// Preço promocional
  final double? salePrice;
  
  /// Quantidade em estoque
  final int stock;
  
  /// SKU (código do produto)
  final String? sku;
  
  /// Categoria do produto
  final String? category;
  
  /// URL da imagem do produto
  final String? imageUrl;
  
  /// Se o produto está ativo
  final bool isActive;
  
  /// ID do usuário que criou
  final String createdBy;
  
  /// Data de criação
  final DateTime createdAt;
  
  /// Data da última atualização
  final DateTime updatedAt;
  
  /// Metadados adicionais
  final Map<String, dynamic>? metadata;

  const ProductModel({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    required this.price,
    this.salePrice,
    this.stock = 0,
    this.sku,
    this.category,
    this.imageUrl,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Cria uma instância a partir de JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      salePrice: json['sale_price'] != null 
          ? (json['sale_price'] as num).toDouble() 
          : null,
      stock: json['stock'] as int? ?? 0,
      sku: json['sku'] as String?,
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
      'sale_price': salePrice,
      'stock': stock,
      'sku': sku,
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
  ProductModel copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? description,
    double? price,
    double? salePrice,
    int? stock,
    String? sku,
    String? category,
    String? imageUrl,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ProductModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      stock: stock ?? this.stock,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Retorna o preço efetivo (promocional se disponível)
  double get effectivePrice => salePrice ?? price;
  
  /// Verifica se está em promoção
  bool get isOnSale => salePrice != null && salePrice! < price;
  
  /// Verifica se está em estoque
  bool get inStock => stock > 0;
  
  /// Porcentagem de desconto
  int get discountPercent {
    if (!isOnSale) return 0;
    return ((1 - salePrice! / price) * 100).round();
  }

  @override
  List<Object?> get props => [
    id, tenantId, name, description, price, salePrice, stock,
    sku, category, imageUrl, isActive, createdBy, createdAt, updatedAt, metadata
  ];
  
  @override
  String toString() => 'ProductModel(id: $id, name: $name, price: $price)';
}
