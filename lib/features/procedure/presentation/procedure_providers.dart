import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/procedure.dart';
import '../domain/procedure_service.dart';

// Family provider to list procedures for a patient
final proceduresListProvider = FutureProvider.family
    .autoDispose<List<Procedure>, String>((ref, patientId) async {
      final service = ref.watch(procedureServiceProvider);
      return await service.getProceduresForPatient(patientId);
    });

// Notifier class for managing procedure creations, updates and deletions
class ProcedureController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<bool> createProcedure({
    required String patientId,
    required String description,
    required DateTime date,
    String? tooth,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(procedureServiceProvider);
      await service.createProcedure(
        patientId: patientId,
        description: description,
        date: date,
        tooth: tooth,
        notes: notes,
      );
      ref.invalidate(proceduresListProvider(patientId));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> updateProcedure({
    required String id,
    required String patientId,
    required String description,
    required DateTime date,
    String? tooth,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(procedureServiceProvider);
      await service.updateProcedure(
        id: id,
        patientId: patientId,
        description: description,
        date: date,
        tooth: tooth,
        notes: notes,
      );
      ref.invalidate(proceduresListProvider(patientId));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> deleteProcedure(String id, String patientId) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(procedureServiceProvider);
      await service.deleteProcedure(id);
      ref.invalidate(proceduresListProvider(patientId));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

// Global provider for procedure controller
final procedureControllerProvider =
    NotifierProvider<ProcedureController, AsyncValue<void>>(() {
      return ProcedureController();
    });
