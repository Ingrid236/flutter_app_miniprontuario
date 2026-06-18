import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/procedure_repository.dart';
import 'procedure.dart';

class ProcedureService {
  final ProcedureRepository _procedureRepository;

  ProcedureService(this._procedureRepository);


  Future<Procedure> createProcedure({
    required String patientId,
    required String description,
    required DateTime date,
    String? tooth,
    String? notes,
  }) async {
    final procedure = Procedure(
      id: '', // Backend will assign
      patientId: patientId,
      date: date,
      description: description,
      tooth: tooth,
      notes: notes,
    );
    return await _procedureRepository.createProcedure(patientId, procedure);
  }

  Future<Procedure> updateProcedure({
    required String id,
    required String patientId,
    required String description,
    required DateTime date,
    String? tooth,
    String? notes,
  }) async {
    final procedure = Procedure(
      id: id,
      patientId: patientId,
      date: date,
      description: description,
      tooth: tooth,
      notes: notes,
    );
    return await _procedureRepository.updateProcedure(procedure);
  }

  Future<void> deleteProcedure(String id) async {
    await _procedureRepository.deleteProcedure(id);
  }

  Future<List<Procedure>> getProceduresForPatient(String patientId) async {
    return await _procedureRepository.getProceduresForPatient(patientId);
  }
}

// Provider for ProcedureService
final procedureServiceProvider = Provider<ProcedureService>((ref) {
  final repository = ref.watch(procedureRepositoryProvider);
  return ProcedureService(repository);
});
