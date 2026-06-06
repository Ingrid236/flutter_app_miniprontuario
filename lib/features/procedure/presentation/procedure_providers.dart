import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/secure_storage_service.dart';
import '../../patient/data/patient_repository.dart';
import '../data/procedure_repository.dart';
import '../domain/procedure.dart';
import '../domain/procedure_service.dart';

// Provider for ProcedureService
final procedureServiceProvider = Provider<ProcedureService>((ref) {
  final repository = ref.watch(procedureRepositoryProvider);
  final patientRepository = ref.watch(patientRepositoryProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return ProcedureService(repository, patientRepository, secureStorage);
});

final proceduresListProvider = FutureProvider.family
    .autoDispose<List<Procedure>, String>((ref, patientId) async {
      final service = ref.watch(procedureServiceProvider);
      return await service.getProceduresForPatient(patientId);
    });

// Family provider to get details of a specific procedure
final procedureDetailProvider = FutureProvider.family
    .autoDispose<Procedure?, String>((ref, id) async {
      final service = ref.watch(procedureServiceProvider);
      return await service.getProcedure(id);
    });

// Notifier class for managing procedure creations, updates and deletions
class ProcedureController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<bool> createProcedure({
    required String patientId,
    required String type,
    required DateTime date,
    String? tooth,
    String? observations,
    required String status,
    double? cost,
  }) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(procedureServiceProvider);
      await service.createProcedure(
        patientId: patientId,
        type: type,
        date: date,
        tooth: tooth,
        observations: observations,
        status: status,
        cost: cost,
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
    required String type,
    required DateTime date,
    String? tooth,
    String? observations,
    required String status,
    double? cost,
  }) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(procedureServiceProvider);
      await service.updateProcedure(
        id: id,
        patientId: patientId,
        type: type,
        date: date,
        tooth: tooth,
        observations: observations,
        status: status,
        cost: cost,
      );
      ref.invalidate(proceduresListProvider(patientId));
      ref.invalidate(procedureDetailProvider(id));
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
