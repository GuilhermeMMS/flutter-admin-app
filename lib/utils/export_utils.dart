// Lead Genius Admin - Utils de Exportação
// Utilitários para exportar dados em CSV e PDF.

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../models/lead_model.dart';
import '../models/contract_model.dart';
import '../models/product_model.dart';

/// Exporta lista de leads para CSV
Future<String> exportLeadsToCSV(List<LeadModel> leads) async {
  final headers = [
    'Nome',
    'Email',
    'Telefone',
    'Empresa',
    'Cargo',
    'Origem',
    'Status',
    'Valor Estimado',
    'Data Criação',
  ];

  final rows = leads.map((lead) => [
    lead.name,
    lead.email ?? '',
    lead.phone ?? '',
    lead.company ?? '',
    lead.position ?? '',
    lead.source ?? '',
    lead.statusDisplay,
    lead.estimatedValue?.toString() ?? '0',
    DateFormat('dd/MM/yyyy').format(lead.createdAt),
  ]).toList();

  return _generateCSV(headers, rows, 'leads');
}

/// Exporta lista de contratos para CSV
Future<String> exportContractsToCSV(List<ContractModel> contracts) async {
  final headers = [
    'Número',
    'Cliente',
    'Email',
    'Telefone',
    'Valor',
    'Desconto',
    'Valor Final',
    'Parcelas',
    'Status',
    'Data Início',
    'Data Término',
  ];

  final rows = contracts.map((contract) => [
    contract.contractNumber ?? '',
    contract.customerName,
    contract.customerEmail ?? '',
    contract.customerPhone ?? '',
    contract.value.toString(),
    contract.discount.toString(),
    contract.finalValue.toString(),
    contract.installments.toString(),
    contract.statusDisplay,
    DateFormat('dd/MM/yyyy').format(contract.startDate),
    contract.endDate != null ? DateFormat('dd/MM/yyyy').format(contract.endDate!) : '',
  ]).toList();

  return _generateCSV(headers, rows, 'contratos');
}

/// Exporta lista de produtos para CSV
Future<String> exportProductsToCSV(List<ProductModel> products) async {
  final headers = [
    'Nome',
    'Descrição',
    'Preço',
    'Preço Promocional',
    'Estoque',
    'SKU',
    'Categoria',
    'Ativo',
  ];

  final rows = products.map((product) => [
    product.name,
    product.description ?? '',
    product.price.toString(),
    product.salePrice?.toString() ?? '',
    product.stock.toString(),
    product.sku ?? '',
    product.category ?? '',
    product.isActive ? 'Sim' : 'Não',
  ]).toList();

  return _generateCSV(headers, rows, 'produtos');
}

/// Gera CSV e salva em arquivo
Future<String> _generateCSV(
  List<String> headers,
  List<List<String>> rows,
  String fileName,
) async {
  final data = [headers, ...rows];
  final csv = const ListToCsvConverter().convert(data);
  
  final directory = await getApplicationDocumentsDirectory();
  final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final file = File('${directory.path}/${fileName}_$timestamp.csv');
  
  await file.writeAsString(csv);
  
  return file.path;
}

/// Compartilha arquivo
Future<void> shareFile(String filePath, {String? subject}) async {
  await Share.shareXFiles(
    [XFile(filePath)],
    subject: subject,
  );
}

/// Exporta e compartilha leads
Future<void> exportAndShareLeads(List<LeadModel> leads) async {
  final filePath = await exportLeadsToCSV(leads);
  await shareFile(filePath, subject: 'Exportação de Leads');
}

/// Exporta e compartilha contratos
Future<void> exportAndShareContracts(List<ContractModel> contracts) async {
  final filePath = await exportContractsToCSV(contracts);
  await shareFile(filePath, subject: 'Exportação de Contratos');
}

/// Exporta e compartilha produtos
Future<void> exportAndShareProducts(List<ProductModel> products) async {
  final filePath = await exportProductsToCSV(products);
  await shareFile(filePath, subject: 'Exportação de Produtos');
}
