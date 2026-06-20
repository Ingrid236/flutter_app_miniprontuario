import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../domain/patient.dart';
import 'patient_providers.dart';

class PatientFormScreen extends ConsumerStatefulWidget {
  final String? patientId;
  const PatientFormScreen({super.key, this.patientId});

  @override
  ConsumerState<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends ConsumerState<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _systemicDiseasesController = TextEditingController();
  final _medicationsController = TextEditingController();

  final _cpfFormatter = AppFormatters.cpfFormatter;
  final _phoneFormatter = AppFormatters.phoneFormatter;

  DateTime? _selectedBirthDate;
  bool _isInitialized = false;

  bool get _isEditMode => widget.patientId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _allergiesController.dispose();
    _systemicDiseasesController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  void _initializeFields(Patient patient) {
    if (_isInitialized) return;
    _nameController.text = patient.name;
    _cpfController.text = patient.cpf;
    _phoneController.text = patient.phone ?? '';
    _selectedBirthDate = patient.birthDate;
    _allergiesController.text = patient.allergies ?? '';
    _systemicDiseasesController.text = patient.systemicDiseases ?? '';
    _medicationsController.text = patient.medications ?? '';
    _isInitialized = true;
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF06B6D4),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione a data de nascimento.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final controller = ref.read(patientControllerProvider.notifier);
    bool success;

    if (_isEditMode) {
      success = await controller.updatePatient(
        id: widget.patientId!,
        name: _nameController.text.trim(),
        birthDate: _selectedBirthDate!,
        cpf: _cpfController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        allergies: _allergiesController.text.trim().isEmpty
            ? null
            : _allergiesController.text.trim(),
        systemicDiseases: _systemicDiseasesController.text.trim().isEmpty
            ? null
            : _systemicDiseasesController.text.trim(),
        medications: _medicationsController.text.trim().isEmpty
            ? null
            : _medicationsController.text.trim(),
      );
    } else {
      success = await controller.createPatient(
        name: _nameController.text.trim(),
        birthDate: _selectedBirthDate!,
        cpf: _cpfController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        allergies: _allergiesController.text.trim().isEmpty
            ? null
            : _allergiesController.text.trim(),
        systemicDiseases: _systemicDiseasesController.text.trim().isEmpty
            ? null
            : _systemicDiseasesController.text.trim(),
        medications: _medicationsController.text.trim().isEmpty
            ? null
            : _medicationsController.text.trim(),
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Dados atualizados com sucesso!'
                : 'Paciente cadastrado com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else if (mounted) {
      final errorState = ref.read(patientControllerProvider);
      final errorMsg = errorState.maybeWhen(
        error: (err, _) => err.toString().replaceAll('Exception: ', ''),
        orElse: () => 'Erro ao salvar paciente.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientState = _isEditMode
        ? ref.watch(patientDetailProvider(widget.patientId!))
        : null;
    final controllerState = ref.watch(patientControllerProvider);
    final isLoading = controllerState is AsyncLoading;

    if (patientState != null) {
      return patientState.when(
        data: (patient) {
          if (patient == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Editar Paciente')),
              body: const Center(
                child: Text(
                  'Paciente não encontrado.',
                ),
              ),
            );
          }
          _initializeFields(patient);
          return _buildFormScaffold(isLoading);
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Scaffold(
          body: Center(
            child: Text(
              'Erro ao carregar dados: $err',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      );
    }

    return _buildFormScaffold(isLoading);
  }

  Widget _buildFormScaffold(bool isLoading) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_isEditMode ? 'Editar Paciente' : 'Cadastrar Paciente'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient Info Section Card
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Informações Pessoais',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    _buildLabel('Nome Completo'),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Nome do Paciente',
                      icon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nome do paciente ausente. O nome é obrigatório para identificação no prontuário. Por favor, insira o nome completo do paciente.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // CPF & Birth Date Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel('CPF'),
                              _buildTextField(
                                controller: _cpfController,
                                hint: '000.000.000-00',
                                icon: Icons.badge_outlined,
                                keyboardType: TextInputType.number,
                                inputFormatters: [_cpfFormatter],
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'CPF ausente. O CPF é obrigatório para faturamento e identificação única. Por favor, insira o CPF completo do paciente.';
                                  }
                                  final cleanCpf = value.replaceAll(RegExp(r'[^0-9]'), '');
                                  if (cleanCpf.length != 11) {
                                    return 'CPF incompleto. O CPF do paciente deve conter exatamente 11 dígitos numéricos. Por favor, preencha o CPF por completo (000.000.000-00).';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel('Nascimento'),
                              GestureDetector(
                                onTap: () => _selectBirthDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _selectedBirthDate == null
                                              ? 'DD/MM/AAAA'
                                              : _formatDate(_selectedBirthDate),
                                          style: TextStyle(
                                            color: _selectedBirthDate == null
                                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                                : Theme.of(context).colorScheme.onSurface,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    _buildLabel('Telefone / Celular'),
                    _buildTextField(
                      controller: _phoneController,
                      hint: '(00) 90000-0000',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [_phoneFormatter],
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (clean.length <= 10) {
                          _phoneFormatter.updateMask(mask: '(##) ####-####');
                        } else {
                          _phoneFormatter.updateMask(mask: '(##) #####-####');
                        }
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Telefone ausente. O telefone é necessário para comunicação com o paciente. Por favor, insira o número de telefone com DDD.';
                        }
                        final cleanPhone = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (cleanPhone.length < 10) {
                          return 'Telefone incompleto. O número inserido é curto demais. Por favor, insira o DDD + 8 ou 9 dígitos.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Clinical Notes Card
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Histórico Clínico (Opcional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Allergies
                    _buildLabel('Alergias'),
                    _buildTextField(
                      controller: _allergiesController,
                      hint: 'E.g. Penicilina, Corantes, ANESTÉSICOS',
                      icon: Icons.warning_amber_outlined,
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Systemic Diseases
                    _buildLabel('Doenças Sistêmicas'),
                    _buildTextField(
                      controller: _systemicDiseasesController,
                      hint: 'E.g. Diabetes, Hipertensão, Hemofilia',
                      icon: Icons.healing_outlined,
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Medications
                    _buildLabel('Medicamentos em Uso'),
                    _buildTextField(
                      controller: _medicationsController,
                      hint: 'E.g. AAS, Anticoagulantes, Insulina',
                      icon: Icons.medication_outlined,
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : const Text(
                        'Salvar Paciente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      textInputAction: textInputAction,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}
