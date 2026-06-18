import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../domain/procedure.dart';

abstract class ProcedureRepository {
  Future<Procedure> createProcedure(String patientId, Procedure procedure);
  Future<Procedure> updateProcedure(Procedure procedure);
  Future<void> deleteProcedure(String id);
  Future<List<Procedure>> getProceduresForPatient(String patientId);
}

class RemoteProcedureRepository implements ProcedureRepository {
  final ApiClient _api;

  RemoteProcedureRepository(this._api);

  @override
  Future<Procedure> createProcedure(String patientId, Procedure procedure) async {
    final data = await _api.post(
      ApiConstants.proceduresForPatient(patientId),
      procedure.toJson(),
    );
    return Procedure.fromJson(data);
  }

  @override
  Future<Procedure> updateProcedure(Procedure procedure) async {
    final data = await _api.put(
      ApiConstants.procedure(procedure.id),
      procedure.toJson(),
    );
    return Procedure.fromJson(data);
  }

  @override
  Future<void> deleteProcedure(String id) async {
    await _api.delete(ApiConstants.procedure(id));
  }

  @override
  Future<List<Procedure>> getProceduresForPatient(String patientId) async {
    final list = await _api.getList(
      ApiConstants.proceduresForPatient(patientId),
    );
    return list
        .map((e) => Procedure.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

// Provider for ProcedureRepository
final procedureRepositoryProvider = Provider<ProcedureRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return RemoteProcedureRepository(api);
});
