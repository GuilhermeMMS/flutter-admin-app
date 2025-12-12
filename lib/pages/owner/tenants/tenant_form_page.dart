// Lead Genius Admin - Formulário de Tenant
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/input_text.dart';
import '../../widgets/button_primary.dart';
import '../../widgets/modal_confirm.dart';
import '../../app/constants.dart';

class TenantFormPage extends ConsumerStatefulWidget {
  final String? tenantId;
  const TenantFormPage({super.key, this.tenantId});

  @override
  ConsumerState<TenantFormPage> createState() => _TenantFormPageState();
}

class _TenantFormPageState extends ConsumerState<TenantFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerPasswordController = TextEditingController();
  String _plan = 'free';
  bool _isLoading = false;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: Implementar criação de tenant via admin API
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    showSuccessSnackbar(context, 'Tenant criado!');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Tenant')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputText(label: 'Nome do Tenant *', controller: _nameController, enabled: !_isLoading,
                validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null),
              const SizedBox(height: 16),
              InputText(label: 'Nome do Administrador *', controller: _ownerNameController, enabled: !_isLoading,
                validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null),
              const SizedBox(height: 16),
              InputEmail(controller: _ownerEmailController, enabled: !_isLoading),
              const SizedBox(height: 16),
              InputPassword(controller: _ownerPasswordController, enabled: !_isLoading),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _plan,
                decoration: const InputDecoration(labelText: 'Plano'),
                items: TenantPlans.all.map((p) => DropdownMenuItem(value: p, child: Text(TenantPlans.displayName(p)))).toList(),
                onChanged: _isLoading ? null : (v) => setState(() => _plan = v!),
              ),
              const SizedBox(height: 32),
              ButtonPrimary(label: 'Criar Tenant', onPressed: _isLoading ? null : _handleSave, isLoading: _isLoading, icon: Icons.add),
            ],
          ),
        ),
      ),
    );
  }
}
