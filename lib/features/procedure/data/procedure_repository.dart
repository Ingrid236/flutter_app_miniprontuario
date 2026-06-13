import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/procedure.dart';

abstract class ProcedureRepository {
  Future<void> createProcedure(Procedure procedure);
  Future<void> updateProcedure(Procedure procedure);
  Future<void> deleteProcedure(String id);
  Future<Procedure?> getProcedureById(String id);
  Future<List<Procedure>> getProceduresForPatient(String patientId);
}

class RestProcedureRepository implements ProcedureRepository {
  final ApiClient _apiClient;

  RestProcedureRepository(this._apiClient);

  @override
  Future<void> createProcedure(Procedure procedure) async {
    await _apiClient.dio.post(
      '/patients/${procedure.patientId}/procedures',
      data: procedure.toMap(),
    );
  }

  @override
  Future<void> updateProcedure(Procedure procedure) async {
    await _apiClient.dio.put(
      '/procedures/${procedure.id}',
      data: procedure.toMap(),
    );
  }

  @override
  Future<void> deleteProcedure(String id) async {
    await _apiClient.dio.delete('/procedures/$id');
  }

  @override
  Future<Procedure?> getProcedureById(String id) async {
    final response = await _apiClient.dio.get('/procedures/$id');
    if (response.data != null) {
      return Procedure.fromMap(response.data as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<List<Procedure>> getProceduresForPatient(String patientId) async {
    final response = await _apiClient.dio.get('/patients/$patientId/procedures');
    final list = response.data as List<dynamic>;
    return list.map((map) => Procedure.fromMap(map as Map<String, dynamic>)).toList();
  }
}

final procedureRepositoryProvider = Provider<ProcedureRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RestProcedureRepository(apiClient);
});
