// Lead Genius Admin - Formulário de Produto
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../main.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../widgets/input_text.dart';
import '../../../widgets/button_primary.dart';
import '../../../widgets/modal_confirm.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final String? productId;
  const ProductFormPage({super.key, this.productId});
  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _skuController = TextEditingController();
  bool _isLoading = false;

  bool get isEditing => widget.productId != null;

  @override
  void initState() { super.initState(); if (isEditing) _loadProduct(); }

  Future<void> _loadProduct() async {
    try {
      final response = await supabase.from('products').select().eq('id', widget.productId!).single();
      _nameController.text = response['name'] ?? '';
      _descController.text = response['description'] ?? '';
      _priceController.text = (response['price'] ?? 0).toString();
      _stockController.text = (response['stock'] ?? 0).toString();
      _skuController.text = response['sku'] ?? '';
    } catch (_) {}
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final tenantId = ref.read(currentTenantIdProvider);
      final userId = ref.read(currentSupabaseUserProvider)?.id;
      final data = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0,
        'stock': int.tryParse(_stockController.text) ?? 0,
        'sku': _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
        'tenant_id': tenantId,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (isEditing) {
        await supabase.from('products').update(data).eq('id', widget.productId!);
      } else {
        data['id'] = const Uuid().v4();
        data['created_by'] = userId;
        data['created_at'] = DateTime.now().toIso8601String();
        data['is_active'] = true;
        await supabase.from('products').insert(data);
      }
      if (!mounted) return;
      showSuccessSnackbar(context, isEditing ? 'Produto atualizado!' : 'Produto criado!');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Erro ao salvar');
    } finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Produto' : 'Novo Produto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputText(label: 'Nome *', controller: _nameController, enabled: !_isLoading, validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null),
              const SizedBox(height: 16),
              InputText(label: 'Descrição', controller: _descController, enabled: !_isLoading, maxLines: 3),
              const SizedBox(height: 16),
              InputText(label: 'Preço (R\$) *', controller: _priceController, enabled: !_isLoading, keyboardType: TextInputType.number, validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null),
              const SizedBox(height: 16),
              InputText(label: 'Estoque', controller: _stockController, enabled: !_isLoading, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              InputText(label: 'SKU', controller: _skuController, enabled: !_isLoading),
              const SizedBox(height: 32),
              ButtonPrimary(label: isEditing ? 'Salvar' : 'Criar Produto', onPressed: _isLoading ? null : _handleSave, isLoading: _isLoading, icon: Icons.save),
            ],
          ),
        ),
      ),
    );
  }
}
