// Lead Genius Admin - Formulário de Lead
// Tela de criação/edição de lead.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../models/lead_model.dart';
import '../../../services/lead_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../widgets/input_text.dart';
import '../../../widgets/button_primary.dart';
import '../../../widgets/modal_confirm.dart';
import '../../../widgets/loading_widget.dart';
import '../../../app/constants.dart';

class LeadFormPage extends ConsumerStatefulWidget {
  final String? leadId;

  const LeadFormPage({super.key, this.leadId});

  @override
  ConsumerState<LeadFormPage> createState() => _LeadFormPageState();
}

class _LeadFormPageState extends ConsumerState<LeadFormPage> {
  final _formKey = GlobalKey<FormState>();
  final LeadService _leadService = LeadService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _sourceController = TextEditingController();
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();

  String _status = 'novo';
  bool _isLoading = false;
  bool _isLoadingData = true;

  bool get isEditing => widget.leadId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadLead();
    } else {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _loadLead() async {
    try {
      final lead = await _leadService.getLeadById(widget.leadId!);
      _nameController.text = lead.name;
      _emailController.text = lead.email ?? '';
      _phoneController.text = lead.phone ?? '';
      _companyController.text = lead.company ?? '';
      _positionController.text = lead.position ?? '';
      _sourceController.text = lead.source ?? '';
      _valueController.text = lead.estimatedValue?.toString() ?? '';
      _notesController.text = lead.notes ?? '';
      _status = lead.status;
      setState(() => _isLoadingData = false);
    } catch (e) {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final tenantId = ref.read(currentTenantIdProvider);
      final userId = ref.read(currentSupabaseUserProvider)?.id;

      if (isEditing) {
        await _leadService.updateLead(widget.leadId!, {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          'company': _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
          'position': _positionController.text.trim().isEmpty ? null : _positionController.text.trim(),
          'source': _sourceController.text.trim().isEmpty ? null : _sourceController.text.trim(),
          'estimated_value': _valueController.text.isEmpty ? null : double.tryParse(_valueController.text),
          'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          'status': _status,
        });
      } else {
        final lead = LeadModel(
          id: const Uuid().v4(),
          tenantId: tenantId ?? '',
          name: _nameController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          company: _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
          position: _positionController.text.trim().isEmpty ? null : _positionController.text.trim(),
          source: _sourceController.text.trim().isEmpty ? null : _sourceController.text.trim(),
          estimatedValue: _valueController.text.isEmpty ? null : double.tryParse(_valueController.text),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          status: _status,
          ownerUserId: userId ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _leadService.createLead(lead);
      }

      if (!mounted) return;
      showSuccessSnackbar(context, isEditing ? 'Lead atualizado!' : 'Lead criado!');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Erro ao salvar: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(),
        body: const LoadingWidget(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Lead' : 'Novo Lead'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputText(
                label: 'Nome *',
                controller: _nameController,
                enabled: !_isLoading,
                prefixIcon: const Icon(Icons.person_outline),
                validator: (v) => v?.isEmpty == true ? 'Nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),

              InputText(
                label: 'Email',
                controller: _emailController,
                enabled: !_isLoading,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              const SizedBox(height: 16),

              InputText(
                label: 'Telefone',
                controller: _phoneController,
                enabled: !_isLoading,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              const SizedBox(height: 16),

              InputText(
                label: 'Empresa',
                controller: _companyController,
                enabled: !_isLoading,
                prefixIcon: const Icon(Icons.business_outlined),
              ),
              const SizedBox(height: 16),

              InputText(
                label: 'Cargo',
                controller: _positionController,
                enabled: !_isLoading,
                prefixIcon: const Icon(Icons.work_outline),
              ),
              const SizedBox(height: 16),

              InputText(
                label: 'Origem',
                controller: _sourceController,
                enabled: !_isLoading,
                hint: 'Ex: site, indicação, anúncio',
                prefixIcon: const Icon(Icons.source_outlined),
              ),
              const SizedBox(height: 16),

              InputText(
                label: 'Valor Estimado (R\$)',
                controller: _valueController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: LeadStatus.all.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(LeadStatus.displayName(s)),
                )).toList(),
                onChanged: _isLoading ? null : (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),

              InputText(
                label: 'Observações',
                controller: _notesController,
                enabled: !_isLoading,
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              ButtonPrimary(
                label: isEditing ? 'Salvar Alterações' : 'Criar Lead',
                onPressed: _isLoading ? null : _handleSave,
                isLoading: _isLoading,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
