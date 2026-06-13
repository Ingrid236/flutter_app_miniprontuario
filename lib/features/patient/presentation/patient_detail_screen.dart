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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Ficha do Paciente'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary),
            onPressed: () => context.push('/patients/$patientId/edit'),
            tooltip: 'Editar Paciente',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
            onPressed: () => _confirmDelete(context, ref),
            tooltip: 'Excluir Paciente',
          ),
        ],
      ),
      body: patientState.when(
        data: (patient) {
          if (patient == null) {
            return Center(
              child: Text(
                'Paciente não encontrado.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16),
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
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        Icons.cake_outlined,
                        'Nascimento: ${_formatDate(patient.birthDate)} ($age anos)',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        Icons.badge_outlined,
                        'CPF: ${patient.cpf}',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        Icons.phone_outlined,
                        'Telefone: ${patient.phone}',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Clinical alerts header
                Text(
                  'Alertas Clínicos e Anamnese',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // Allergies Card (Red alert if exists)
                _buildAlertCard(
                  context: context,
                  title: 'Alergias',
                  content: patient.allergies,
                  icon: Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  emptyText: 'Nenhuma alergia relatada.',
                ),
                const SizedBox(height: 12),

                // Medications Card (Amber/Orange alert)
                _buildAlertCard(
                  context: context,
                  title: 'Medicamentos em Uso',
                  content: patient.medications,
                  icon: Icons.medication_liquid_outlined,
                  color: Colors.orangeAccent,
                  emptyText: 'Nenhum medicamento de uso contínuo informado.',
                ),
                const SizedBox(height: 12),

                // Chronic Diseases Card (Blue/Teal alert)
                _buildAlertCard(
                  context: context,
                  title: 'Doenças Crônicas',
                  content: patient.chronicDiseases,
                  icon: Icons.healing_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                  emptyText: 'Nenhuma doença crônica relatada.',
                ),

                const SizedBox(height: 20),

                Text(
                  'Análise de Risco por Inteligência Artificial',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),

                Consumer(
                  builder: (context, ref, child) {
                    final aiState = ref.watch(patientAiAnalysisProvider(patientId));
                    return aiState.when(
                      data: (analysis) => Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.psychology_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 26,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Relatório de Risco Clínico IA',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              analysis,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      loading: () => Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('A IA está analisando o prontuário...'),
                          ],
                        ),
                      ),
                      error: (err, _) => Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          'Erro ao gerar análise da IA: $err',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Procedures History Title and add procedure
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Text(
                        'Histórico de Procedimentos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.push('/patients/$patientId/procedures/new'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAlertCard({
    required BuildContext context,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasContent
              ? color.withOpacity(0.4)
              : Theme.of(context).colorScheme.outlineVariant,
          width: hasContent ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: hasContent ? color : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
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
                    color: hasContent ? color : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasContent ? content : emptyText,
                  style: TextStyle(
                    fontSize: 14,
                    color: hasContent
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
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
