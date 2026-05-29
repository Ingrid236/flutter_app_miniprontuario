import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../procedure/presentation/procedure_timeline_widget.dart';
import 'patient_providers.dart';

class PatientDetailScreen extends ConsumerWidget {
  final String patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Paciente'),
        content: const Text(
          'Aviso: Isso irá excluir permanentemente este paciente e todos os seus registros de procedimentos associados.\n\nDeseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref
          .read(patientControllerProvider.notifier)
          .deletePatient(patientId);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paciente excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao excluir paciente.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientState = ref.watch(patientDetailProvider(patientId));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Ficha do Paciente'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF06B6D4)),
            onPressed: () => context.push('/patients/$patientId/edit'),
            tooltip: 'Editar Paciente',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context, ref),
            tooltip: 'Excluir Paciente',
          ),
        ],
      ),
      body: patientState.when(
        data: (patient) {
          if (patient == null) {
            return const Center(
              child: Text(
                'Paciente não encontrado.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final age = _calculateAge(patient.birthDate);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Patient Main Profile Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF334155).withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.cake_outlined,
                        'Nascimento: ${_formatDate(patient.birthDate)} ($age anos)',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.badge_outlined,
                        'CPF: ${patient.cpf}',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.phone_outlined,
                        'Telefone: ${patient.phone}',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Clinical alerts header
                const Text(
                  'Alertas Clínicos e Anamnese',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF06B6D4),
                  ),
                ),
                const SizedBox(height: 12),

                // Allergies Card (Red alert if exists)
                _buildAlertCard(
                  title: 'Alergias',
                  content: patient.allergies,
                  icon: Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  emptyText: 'Nenhuma alergia relatada.',
                ),
                const SizedBox(height: 12),

                // Medications Card (Amber/Orange alert)
                _buildAlertCard(
                  title: 'Medicamentos em Uso',
                  content: patient.medications,
                  icon: Icons.medication_liquid_outlined,
                  color: Colors.orangeAccent,
                  emptyText: 'Nenhum medicamento de uso contínuo informado.',
                ),
                const SizedBox(height: 12),

                // Chronic Diseases Card (Blue/Teal alert)
                _buildAlertCard(
                  title: 'Doenças Crônicas',
                  content: patient.chronicDiseases,
                  icon: Icons.healing_outlined,
                  color: const Color(0xFF3B82F6),
                  emptyText: 'Nenhuma doença crônica relatada.',
                ),

                const SizedBox(height: 24),

                // Procedures History Title and add procedure
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Histórico de Procedimentos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.push('/patients/$patientId/procedures/new'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06B6D4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'Adicionar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                ProcedureTimelineWidget(patientId: patientId),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Erro ao carregar dados: $err',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String? content,
    required IconData icon,
    required Color color,
    required String emptyText,
  }) {
    final hasContent = content != null && content.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasContent
              ? color.withOpacity(0.4)
              : const Color(0xFF334155).withOpacity(0.3),
          width: hasContent ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: hasContent ? color : const Color(0xFF475569),
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: hasContent ? color : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasContent ? content : emptyText,
                  style: TextStyle(
                    fontSize: 14,
                    color: hasContent
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF475569),
                    fontStyle: hasContent ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
