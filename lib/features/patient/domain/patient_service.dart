import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/patient_repository.dart';
import 'patient.dart';

class PatientService {
  final PatientRepository _patientRepository;

  PatientService(this._patientRepository);

  Future<Patient> createPatient({
    required String name,
    required DateTime birthDate,
    required String cpf,
    String? phone,
    String? allergies,
    String? systemicDiseases,
    String? medications,
  }) async {
    final patient = Patient(
      id: '', // Backend will assign ID
      name: name,
      birthDate: birthDate,
      cpf: cpf,
      phone: phone,
      allergies: allergies,
      systemicDiseases: systemicDiseases,
      medications: medications,
    );
    return await _patientRepository.createPatient(patient);
  }

  Future<Patient> updatePatient({
    required String id,
    required String name,
    required DateTime birthDate,
    required String cpf,
    String? phone,
    String? allergies,
    String? systemicDiseases,
    String? medications,
  }) async {
    final patient = Patient(
      id: id,
      name: name,
      birthDate: birthDate,
      cpf: cpf,
      phone: phone,
      allergies: allergies,
      systemicDiseases: systemicDiseases,
      medications: medications,
    );
    return await _patientRepository.updatePatient(patient);
  }

  Future<void> deletePatient(String id) async {
    await _patientRepository.deletePatient(id);
  }

  Future<Patient?> getPatient(String id) async {
    return await _patientRepository.getPatientById(id);
  }

  Future<List<Patient>> getPatients() async {
    return await _patientRepository.listPatients();
  }

  Future<List<Patient>> search(String query) async {
    return await _patientRepository.searchPatients(query);
  }
}

// Provider for PatientService
final patientServiceProvider = Provider<PatientService>((ref) {
  final repository = ref.watch(patientRepositoryProvider);
  return PatientService(repository);
});


