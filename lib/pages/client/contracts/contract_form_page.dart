// Lead Genius Admin - Formulário de Contrato
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../main.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../widgets/input_text.dart';
import '../../../widgets/button_primary.dart';
import '../../../widgets/modal_confirm.dart';
import '../../../app/constants.dart';

class ContractFormPage extends ConsumerStatefulWidget {
  final String? contractId;
  const ContractFormPage({super.key, this.contractId});
  @override
  ConsumerState<ContractFormPage> createState() => _ContractFormPageState();
}

class _ContractFormPageState extends ConsumerState<ContractFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  String _status = 'rascunho';
  int _installments = 1;
  bool _isLoading = false;

  bool get isEditing => widget.contractId != null;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final tenantId = ref.read(currentTenantIdProvider);
      final userId = ref.read(currentSupabaseUserProvider)?.id;
      final value = double.tryParse(_valueController.text) ?? 0;
      final data = {
        'customer_name': _customerNameController.text.trim(),
        'customer_email': _customerEmailController.text.trim().isEmpty ? null : _customerEmailController.text.trim(),
        'customer_phone': _customerPhoneController.text.trim().isEmpty ? null : _customerPhoneController.text.trim(),
        'value': value, 'discount': 0, 'final_value': value,
        'installments': _installments, 'status': _status,
        'start_date': DateTime.now().toIso8601String(),
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        'tenant_id': tenantId,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (isEditing) {
        await supabase.from('contracts').update(data).eq('id', widget.contractId!);
      } else {
        data['id'] = const Uuid().v4();
        data['created_by'] = userId;
        data['created_at'] = DateTime.now().toIso8601String();
        await supabase.from('contracts').insert(data);
      }
      if (!mounted) return;
      showSuccessSnackbar(context, isEditing ? 'Contrato atualizado!' : 'Contrato criado!');
      context.pop();
    } catch (e) { if (!mounted) return; showErrorSnackbar(context, 'Erro ao salvar'); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Contrato' : 'Novo Contrato')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputText(label: 'Nome do Cliente *', controller: _customerNameController, enabled: !_isLoading, validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null),
              const SizedBox(height: 16),
              InputText(label: 'Email', controller: _customerEmailController, enabled: !_isLoading, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              InputText(label: 'Telefone', controller: _customerPhoneController, enabled: !_isLoading, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              InputText(label: 'Valor (R\$) *', controller: _valueController, enabled: !_isLoading, keyboardType: TextInputType.number, validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _installments,
                decoration: const InputDecoration(labelText: 'Parcelas'),
                items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}x'))),
                onChanged: _isLoading ? null : (v) => setState(() => _installments = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ContractStatus.all.map((s) => DropdownMenuItem(value: s, child: Text(ContractStatus.displayName(s)))).toList(),
                onChanged: _isLoading ? null : (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),
              InputText(label: 'Observações', controller: _notesController, enabled: !_isLoading, maxLines: 3),
              const SizedBox(height: 32),
              ButtonPrimary(label: isEditing ? 'Salvar' : 'Criar Contrato', onPressed: _isLoading ? null : _handleSave, isLoading: _isLoading, icon: Icons.save),
            ],
          ),
        ),
      ),
    );
  }
}
