import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/network/ia_service.dart';
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

  final _descriptionController = TextEditingController();
  final _toothController = TextEditingController();
  final _notesController = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();

  DateTime? _selectedDate;
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isTranscribing = false;

  bool get _isEditMode => widget.procedureId != null;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _toothController.dispose();
    _notesController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _initializeFields(
    String? description,
    String? tooth,
    String? notes,
    DateTime? date,
  ) {
    if (_isInitialized) return;
    _descriptionController.text = description ?? '';
    _toothController.text = tooth ?? '';
    _notesController.text = notes ?? '';
    _selectedDate = date ?? DateTime.now();
    _isInitialized = true;
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Pare de gravar
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        if (path != null) {
          _isTranscribing = true;
        }
      });

      if (path != null) {
        try {
          final iaService = ref.read(iaServiceProvider);
          final text = await iaService.transcreverAudio(File(path));
          
          setState(() {
            if (_notesController.text.isNotEmpty) {
              _notesController.text += ' $text';
            } else {
              _notesController.text = text;
            }
          });
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro na transcrição: $e'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isTranscribing = false;
            });
          }
        }
      }
    } else {
      // Iniciar gravação
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissão de microfone negada.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      setState(() {
        _isRecording = true;
      });
    }
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

    final controller = ref.read(procedureControllerProvider.notifier);
    bool success;

    if (_isEditMode) {
      success = await controller.updateProcedure(
        id: widget.procedureId!,
        patientId: widget.patientId,
        description: _descriptionController.text.trim(),
        date: _selectedDate!,
        tooth: _toothController.text.trim().isEmpty
            ? null
            : _toothController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    } else {
      success = await controller.createProcedure(
        patientId: widget.patientId,
        description: _descriptionController.text.trim(),
        date: _selectedDate!,
        tooth: _toothController.text.trim().isEmpty
            ? null
            : _toothController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
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
    // For edit mode, load from the procedures list for this patient
    if (_isEditMode) {
      final proceduresAsync = ref.watch(
        proceduresListProvider(widget.patientId),
      );
      return proceduresAsync.when(
        data: (procedures) {
          final procedure = procedures.where(
            (p) => p.id == widget.procedureId,
          ).firstOrNull;
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
          _initializeFields(
            procedure.description,
            procedure.tooth,
            procedure.notes,
            procedure.date,
          );
          final controllerState = ref.watch(procedureControllerProvider);
          final isLoading = controllerState is AsyncLoading;
          return _buildFormScaffold(isLoading);
        },
        loading: () => const Scaffold(
          backgroundColor: Color(0xFF0F172A),
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

    final controllerState = ref.watch(procedureControllerProvider);
    final isLoading = controllerState is AsyncLoading;
    return _buildFormScaffold(isLoading);
  }

  Widget _buildFormScaffold(bool isLoading) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
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
                    color: const Color(0xFF334155).withValues(alpha: 0.5),
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

                    // Description
                    _buildLabel('Descrição do Procedimento'),
                    _buildTextField(
                      controller: _descriptionController,
                      hint: 'E.g. Limpeza dental, Restauração resina composta',
                      icon: Icons.medical_services_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Insira a descrição do procedimento';
                        }
                        return null;
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
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Notes Card
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF334155).withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Notas Clínicas (Opcional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _notesController,
                      hint:
                          'E.g. Procedimento realizado sob anestesia local, sem intercorrências...',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                      suffixIcon: _isTranscribing
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                _isRecording ? Icons.stop_circle : Icons.mic,
                                color: _isRecording ? Colors.redAccent : const Color(0xFF06B6D4),
                              ),
                              onPressed: _toggleRecording,
                            ),
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
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffixIcon,
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
        fillColor: const Color(0xFF0F172A),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
        suffixIcon: suffixIcon,
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
