// Lead Genius Admin - Formulário de Serviço
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../main.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../widgets/input_text.dart';
import '../../../widgets/button_primary.dart';
import '../../../widgets/modal_confirm.dart';

class ServiceFormPage extends ConsumerStatefulWidget {
  final String? serviceId;
  const ServiceFormPage({super.key, this.serviceId});
  @override
  ConsumerState<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends ConsumerState<ServiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  String _billingType = 'projeto';
  bool _isLoading = false;

  bool get isEditing => widget.serviceId != null;

  @override
  void initState() { super.initState(); if (isEditing) _loadService(); }

  Future<void> _loadService() async {
    try {
      final response = await supabase.from('services').select().eq('id', widget.serviceId!).single();
      _nameController.text = response['name'] ?? '';
      _descController.text = response['description'] ?? '';
      _priceController.text = (response['price'] ?? 0).toString();
      _billingType = response['billing_type'] ?? 'projeto';
      setState(() {});
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
        'billing_type': _billingType,
        'tenant_id': tenantId,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (isEditing) {
        await supabase.from('services').update(data).eq('id', widget.serviceId!);
      } else {
        data['id'] = const Uuid().v4();
        data['created_by'] = userId;
        data['created_at'] = DateTime.now().toIso8601String();
        data['is_active'] = true;
        await supabase.from('services').insert(data);
      }
      if (!mounted) return;
      showSuccessSnackbar(context, isEditing ? 'Serviço atualizado!' : 'Serviço criado!');
      context.pop();
    } catch (e) { if (!mounted) return; showErrorSnackbar(context, 'Erro ao salvar'); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Serviço' : 'Novo Serviço')),
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
              DropdownButtonFormField<String>(
                value: _billingType,
                decoration: const InputDecoration(labelText: 'Tipo de Cobrança'),
                items: const [
                  DropdownMenuItem(value: 'hora', child: Text('Por Hora')),
                  DropdownMenuItem(value: 'projeto', child: Text('Por Projeto')),
                  DropdownMenuItem(value: 'mensal', child: Text('Mensal')),
                  DropdownMenuItem(value: 'anual', child: Text('Anual')),
                ],
                onChanged: _isLoading ? null : (v) => setState(() => _billingType = v!),
              ),
              const SizedBox(height: 32),
              ButtonPrimary(label: isEditing ? 'Salvar' : 'Criar Serviço', onPressed: _isLoading ? null : _handleSave, isLoading: _isLoading, icon: Icons.save),
            ],
          ),
        ),
      ),
    );
  }
}
