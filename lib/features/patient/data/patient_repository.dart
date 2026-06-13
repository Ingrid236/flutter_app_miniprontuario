import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/secure_storage_service.dart';
import '../domain/patient.dart';

abstract class PatientRepository {
  Future<void> createPatient(Patient patient);
  Future<void> updatePatient(Patient patient);
  Future<void> deletePatient(String id);
  Future<Patient?> getPatientById(String id);
  Future<List<Patient>> getPatientsForDentist(String dentistId);
  Future<Patient?> getPatientByCpf(String dentistId, String cpf);
  Future<List<Patient>> searchPatients(String dentistId, String query);
}

class RestPatientRepository implements PatientRepository {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  RestPatientRepository(this._apiClient, this._secureStorage);

  @override
  Future<void> createPatient(Patient patient) async {
    await _apiClient.dio.post(
      '/patients',
      data: patient.toMap(),
    );
  }

  @override
  Future<void> updatePatient(Patient patient) async {
    await _apiClient.dio.put(
      '/patients/${patient.id}',
      data: patient.toMap(),
    );
  }

  @override
  Future<void> deletePatient(String id) async {
    await _apiClient.dio.delete('/patients/$id');
  }

  @override
  Future<Patient?> getPatientById(String id) async {
    final response = await _apiClient.dio.get('/patients/$id');
    if (response.data != null) {
      final dentistId = await _secureStorage.getSession() ?? '';
      final pMap = Map<String, dynamic>.from(response.data as Map);
      pMap['dentist_id'] = dentistId;
      return Patient.fromMap(pMap);
    }
    return null;
  }

  @override
  Future<List<Patient>> getPatientsForDentist(String dentistId) async {
    final response = await _apiClient.dio.get('/patients');
    final list = response.data as List<dynamic>;
    return list.map((map) {
      final pMap = Map<String, dynamic>.from(map as Map);
      pMap['dentist_id'] = dentistId;
      return Patient.fromMap(pMap);
    }).toList();
  }

  @override
  Future<Patient?> getPatientByCpf(String dentistId, String cpf) async {
    final list = await getPatientsForDentist(dentistId);
    final results = list.where((p) => p.cpf == cpf).toList();
    return results.isEmpty ? null : results.first;
  }

  @override
  Future<List<Patient>> searchPatients(String dentistId, String query) async {
    final list = await getPatientsForDentist(dentistId);
    if (query.isEmpty) return list;
    final lowercaseQuery = query.toLowerCase();
    return list.where((p) {
      return p.name.toLowerCase().contains(lowercaseQuery) ||
          p.cpf.contains(lowercaseQuery);
    }).toList();
  }
}

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return RestPatientRepository(apiClient, secureStorage);
});
