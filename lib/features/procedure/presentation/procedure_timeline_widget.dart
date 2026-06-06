import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
          'Deseja realmente excluir o procedimento "${procedure.type}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Excluir'),
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
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Center(
              child: Text(
                'Nenhum procedimento registrado ainda.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            final isCompleted = procedure.status == 'Completed';

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
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B), // Green vs Amber
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                        ),
                      ),
                      if (index != procedures.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: Theme.of(context).colorScheme.outlineVariant,
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
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
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
                                  procedure.type,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (isCompleted
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFF59E0B))
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isCompleted
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFF59E0B),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  isCompleted ? 'Concluído' : 'Planejado',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Date, Tooth, Cost Info
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildMetaItem(
                                  context,
                                  Icons.calendar_month_outlined,
                                  _formatDate(procedure.date),
                                ),
                                if (procedure.tooth != null &&
                                    procedure.tooth!.trim().isNotEmpty) ...[
                                  const SizedBox(width: 12),
                                  _buildMetaItem(
                                    context,
                                    Icons.tag,
                                    'Dente ${procedure.tooth}',
                                  ),
                                ],
                                if (procedure.cost != null) ...[
                                  const SizedBox(width: 12),
                                  _buildMetaItem(
                                    context,
                                    Icons.payments_outlined,
                                    NumberFormat.simpleCurrency(
                                      locale: Localizations.maybeLocaleOf(context)?.toString() ?? 'pt_BR',
                                    ).format(procedure.cost),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Observations
                          if (procedure.observations != null &&
                              procedure.observations!.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                procedure.observations!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],

                          const Divider(height: 24),

                          // Card actions (Edit, Delete)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => context.push(
                                  '/patients/$patientId/procedures/${procedure.id}/edit',
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.primary,
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
                                  foregroundColor: Theme.of(context).colorScheme.error,
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
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
