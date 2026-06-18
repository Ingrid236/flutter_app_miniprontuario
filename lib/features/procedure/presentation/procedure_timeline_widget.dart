import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/procedure.dart';
import 'procedure_providers.dart';

class ProcedureTimelineWidget extends ConsumerWidget {
  final String patientId;
  const ProcedureTimelineWidget({super.key, required this.patientId});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Procedure procedure,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Procedimento'),
        content: Text(
          'Deseja realmente excluir o procedimento "${procedure.description}"?',
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
          .read(procedureControllerProvider.notifier)
          .deleteProcedure(procedure.id, patientId);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Procedimento excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proceduresAsync = ref.watch(proceduresListProvider(patientId));

    return proceduresAsync.when(
      data: (procedures) {
        if (procedures.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF334155).withValues(alpha: 0.3),
              ),
            ),
            child: const Center(
              child: Text(
                'Nenhum procedimento registrado ainda.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: procedures.length,
          itemBuilder: (context, index) {
            final procedure = procedures[index];

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Timeline line and node graphics
                  Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // Always green now
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                      if (index != procedures.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: const Color(0xFF334155),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Procedure Card Content
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF334155).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  procedure.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Date, Tooth
                          Row(
                            children: [
                              _buildMetaItem(
                                Icons.calendar_month_outlined,
                                _formatDate(procedure.date),
                              ),
                              if (procedure.tooth != null &&
                                  procedure.tooth!.trim().isNotEmpty) ...[
                                const SizedBox(width: 12),
                                _buildMetaItem(
                                  Icons.tag,
                                  'Dente ${procedure.tooth}',
                                ),
                              ],
                            ],
                          ),

                          // Notes
                          if (procedure.notes != null &&
                              procedure.notes!.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                procedure.notes!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF94A3B8), // Slate 400
                                ),
                              ),
                            ),
                          ],

                          const Divider(color: Color(0xFF334155), height: 24),

                          // Card actions (Edit, Delete)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => context.push(
                                  '/patients/$patientId/procedures/${procedure.id}/edit',
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF06B6D4),
                                ),
                                icon: const Icon(Icons.edit_outlined, size: 14),
                                label: const Text(
                                  'Editar',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () =>
                                    _confirmDelete(context, ref, procedure),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                ),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 14,
                                ),
                                label: const Text(
                                  'Excluir',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Erro ao carregar histórico: $err',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }
}
