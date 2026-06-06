import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/currency_formatter.dart';
import '../domain/procedure.dart';
import 'procedure_providers.dart';

class ProcedureFormScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String? procedureId;
  const ProcedureFormScreen({
    super.key,
    required this.patientId,
    this.procedureId,
  });

  @override
  ConsumerState<ProcedureFormScreen> createState() =>
      _ProcedureFormScreenState();
}

class _ProcedureFormScreenState extends ConsumerState<ProcedureFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _customTypeController = TextEditingController();
  final _toothController = TextEditingController();
  final _costController = TextEditingController();
  final _observationsController = TextEditingController();

  final List<String> _predefinedTypes = [
    'Limpeza Dental',
    'Restauração Resinada',
    'Extração Simples',
    'Tratamento de Canal',
    'Implante Dentário',
    'Ortodontia',
    'Outro (Personalizado)...',
  ];

  String? _selectedType;
  String _selectedStatus = 'Completed';
  DateTime? _selectedDate;
  bool _isInitialized = false;

  bool get _isEditMode => widget.procedureId != null;
  bool get _showCustomTypeField => _selectedType == 'Outro (Personalizado)...';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _customTypeController.dispose();
    _toothController.dispose();
    _costController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  void _initializeFields(Procedure procedure) {
    if (_isInitialized) return;

    if (_predefinedTypes.contains(procedure.type)) {
      _selectedType = procedure.type;
    } else {
      _selectedType = 'Outro (Personalizado)...';
      _customTypeController.text = procedure.type;
    }

    _selectedDate = procedure.date;
    _selectedStatus = procedure.status;
    _toothController.text = procedure.tooth ?? '';
    
    if (procedure.cost != null) {
      final locale = Localizations.maybeLocaleOf(context)?.toString() ?? 'pt_BR';
      final formatter = NumberFormat.simpleCurrency(locale: locale);
      _costController.text = formatter.format(procedure.cost);
    } else {
      _costController.text = '';
    }
    _observationsController.text = procedure.observations ?? '';

    _isInitialized = true;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tipo de procedimento ausente. O tipo de procedimento é obrigatório para registrar a intervenção. Por favor, selecione uma das opções da lista.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final type = _showCustomTypeField
        ? _customTypeController.text.trim()
        : _selectedType!;

    final cleanCostText = _costController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final cost = cleanCostText.isNotEmpty
        ? (double.tryParse(cleanCostText) ?? 0.0) / 100.0
        : null;

    final controller = ref.read(procedureControllerProvider.notifier);
    bool success;

    if (_isEditMode) {
      success = await controller.updateProcedure(
        id: widget.procedureId!,
        patientId: widget.patientId,
        type: type,
        date: _selectedDate!,
        status: _selectedStatus,
        tooth: _toothController.text.trim().isEmpty
            ? null
            : _toothController.text.trim(),
        cost: cost,
        observations: _observationsController.text.trim().isEmpty
            ? null
            : _observationsController.text.trim(),
      );
    } else {
      success = await controller.createProcedure(
        patientId: widget.patientId,
        type: type,
        date: _selectedDate!,
        status: _selectedStatus,
        tooth: _toothController.text.trim().isEmpty
            ? null
            : _toothController.text.trim(),
        cost: cost,
        observations: _observationsController.text.trim().isEmpty
            ? null
            : _observationsController.text.trim(),
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Procedimento atualizado!'
                : 'Procedimento registrado!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else if (mounted) {
      final errorState = ref.read(procedureControllerProvider);
      final errorMsg = errorState.maybeWhen(
        error: (err, _) => err.toString().replaceAll('Exception: ', ''),
        orElse: () => 'Erro ao salvar procedimento.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final procedureState = _isEditMode
        ? ref.watch(procedureDetailProvider(widget.procedureId!))
        : null;
    final controllerState = ref.watch(procedureControllerProvider);
    final isLoading = controllerState is AsyncLoading;

    if (procedureState != null) {
      return procedureState.when(
        data: (procedure) {
          if (procedure == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Editar Procedimento')),
              body: const Center(
                child: Text(
                  'Procedimento não encontrado.',
                ),
              ),
            );
          }
          _initializeFields(procedure);
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
        title: Text(
          _isEditMode ? 'Editar Procedimento' : 'Registrar Procedimento',
        ),
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
              // Info Card
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
                      'Detalhes da Intervenção',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Procedure Type Dropdown
                    _buildLabel('Tipo de Procedimento'),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        prefixIcon: Icon(
                          Icons.medical_services_outlined,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      hint: Text(
                        'Selecione uma opção...',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      items: _predefinedTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedType = val;
                        });
                      },
                    ),

                    if (_showCustomTypeField) ...[
                      const SizedBox(height: 16),
                      _buildLabel('Especificar Procedimento'),
                      _buildTextField(
                        controller: _customTypeController,
                        hint: 'Digite o tipo do procedimento',
                        icon: Icons.edit_note,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (_showCustomTypeField &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Procedimento personalizado não especificado. Como você selecionou a opção "Outro", é necessário descrever qual procedimento foi realizado. Por favor, digite o nome do procedimento no campo correspondente.';
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Status Dropdown
                    _buildLabel('Status'),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        prefixIcon: Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Completed',
                          child: Text('Concluído'),
                        ),
                        DropdownMenuItem(
                          value: 'Planned',
                          child: Text('Planejado'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedStatus = val;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Date & Tooth Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel('Data'),
                              GestureDetector(
                                onTap: () => _selectDate(context),
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
                                          _selectedDate == null
                                              ? 'DD/MM/AAAA'
                                              : _formatDate(_selectedDate),
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel('Dente (Opcional)'),
                              _buildTextField(
                                controller: _toothController,
                                hint: 'Ex. 18, 36',
                                icon: Icons.tag,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value != null && value.trim().isNotEmpty) {
                                    final toothNum = int.tryParse(value.trim());
                                    if (toothNum == null) {
                                      return 'Dente inválido. A identificação do dente deve ser um número inteiro. Por favor, insira apenas números (ex. 18, 36).';
                                    }
                                    final isValidPermanent = (toothNum >= 11 && toothNum <= 18) ||
                                                             (toothNum >= 21 && toothNum <= 28) ||
                                                             (toothNum >= 31 && toothNum <= 38) ||
                                                             (toothNum >= 41 && toothNum <= 48);
                                    final isValidDeciduous = (toothNum >= 51 && toothNum <= 55) ||
                                                             (toothNum >= 61 && toothNum <= 65) ||
                                                             (toothNum >= 71 && toothNum <= 75) ||
                                                             (toothNum >= 81 && toothNum <= 85);
                                    if (!isValidPermanent && !isValidDeciduous) {
                                      return 'Número de dente inválido. A numeração deve seguir o padrão FDI (11-48 para permanentes, 51-85 para decíduos). Por favor, corrija para um dente existente.';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Cost
                    _buildLabel('Valor / Custo (Opcional)'),
                    _buildTextField(
                      controller: _costController,
                      hint: NumberFormat.simpleCurrency(
                        locale: Localizations.maybeLocaleOf(context)?.toString() ?? 'pt_BR',
                      ).format(0.0),
                      icon: Icons.payments_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        CurrencyInputFormatter(
                          locale: Localizations.maybeLocaleOf(context)?.toString() ?? 'pt_BR',
                        ),
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (clean.isEmpty) {
                            return 'Valor inválido. O custo deve ser preenchido com caracteres numéricos. Por favor, digite um valor válido (ex. 150,00).';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Observations Card
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
                      'Observações Clínicas (Opcional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _observationsController,
                      hint:
                          'E.g. Procedimento realizado sob anestesia local, sem intercorrências...',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
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
                        'Salvar Procedimento',
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
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
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
