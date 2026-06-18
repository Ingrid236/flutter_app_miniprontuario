import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../domain/patient.dart';

abstract class PatientRepository {
  Future<Patient> createPatient(Patient patient);
  Future<Patient> updatePatient(Patient patient);
  Future<void> deletePatient(String id);
  Future<Patient?> getPatientById(String id);
  Future<List<Patient>> listPatients();
  Future<List<Patient>> searchPatients(String query);
}

class RemotePatientRepository implements PatientRepository {
  final ApiClient _api;

  RemotePatientRepository(this._api);

  @override
  Future<Patient> createPatient(Patient patient) async {
    final data = await _api.post(ApiConstants.patients, patient.toJson());
    return Patient.fromJson(data);
  }

  @override
  Future<Patient> updatePatient(Patient patient) async {
    final data = await _api.put(
      ApiConstants.patient(patient.id),
      patient.toJson(),
    );
    return Patient.fromJson(data);
  }

  @override
  Future<void> deletePatient(String id) async {
    await _api.delete(ApiConstants.patient(id));
  }

  @override
  Future<Patient?> getPatientById(String id) async {
    try {
      final data = await _api.get(ApiConstants.patient(id));
      return Patient.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<Patient>> listPatients() async {
    final list = await _api.getList(ApiConstants.patients);
    return list
        .map((e) => Patient.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Patient>> searchPatients(String query) async {
    // Client-side filtering over the full list
    final all = await listPatients();
    final q = query.toLowerCase();
    return all
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.cpf.contains(q))
        .toList();
  }
}

// Provider for PatientRepository
final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return RemotePatientRepository(api);
});


