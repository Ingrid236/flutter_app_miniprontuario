import 'package:uuid/uuid.dart';
import '../../../core/utils/secure_storage_service.dart';
import '../data/patient_repository.dart';
import 'patient.dart';

class PatientService {
  final PatientRepository _patientRepository;
  final SecureStorageService _secureStorage;
  static const _uuid = Uuid();

  PatientService(this._patientRepository, this._secureStorage);

  Future<String> _getRequiredSession() async {
    final dentistId = await _secureStorage.getSession();
    if (dentistId == null) {
      throw Exception(
        'Sessão profissional não encontrada. Faça login novamente.',
      );
    }
    return dentistId;
  }

  Future<Patient> createPatient({
    required String name,
    required DateTime birthDate,
    required String cpf,
    required String phone,
    String? allergies,
    String? medications,
    String? chronicDiseases,
  }) async {
    final dentistId = await _getRequiredSession();

    // Check unique CPF per dentist
    final existing = await _patientRepository.getPatientByCpf(dentistId, cpf);
    if (existing != null) {
      throw Exception('Já existe um paciente cadastrado com este CPF.');
    }

    final id = _uuid.v4();
    final now = DateTime.now();

    final patient = Patient(
      id: id,
      dentistId: dentistId,
      name: name,
      birthDate: birthDate,
      cpf: cpf,
      phone: phone,
      allergies: allergies,
      medications: medications,
      chronicDiseases: chronicDiseases,
      createdAt: now,
      updatedAt: now,
    );

    await _patientRepository.createPatient(patient);
    return patient;
  }

  Future<Patient> updatePatient({
    required String id,
    required String name,
    required DateTime birthDate,
    required String cpf,
    required String phone,
    String? allergies,
    String? medications,
    String? chronicDiseases,
  }) async {
    final dentistId = await _getRequiredSession();

    // Get original patient
    final original = await _patientRepository.getPatientById(id);
    if (original == null) {
      throw Exception('Paciente não encontrado.');
    }

    // Check unique CPF per dentist if CPF is changed
    if (original.cpf != cpf) {
      final existing = await _patientRepository.getPatientByCpf(dentistId, cpf);
      if (existing != null) {
        throw Exception('Já existe outro paciente cadastrado com este CPF.');
      }
    }

    final now = DateTime.now();
    final updated = original.copyWith(
      name: name,
      birthDate: birthDate,
      cpf: cpf,
      phone: phone,
      allergies: allergies,
      medications: medications,
      chronicDiseases: chronicDiseases,
      updatedAt: now,
    );

    await _patientRepository.updatePatient(updated);
    return updated;
  }

  Future<void> deletePatient(String id) async {
    await _getRequiredSession();
    await _patientRepository.deletePatient(id);
  }

  Future<Patient?> getPatient(String id) async {
    await _getRequiredSession();
    return await _patientRepository.getPatientById(id);
  }

  Future<List<Patient>> getPatients() async {
    final dentistId = await _getRequiredSession();
    return await _patientRepository.getPatientsForDentist(dentistId);
  }

  Future<List<Patient>> search(String query) async {
    final dentistId = await _getRequiredSession();
    return await _patientRepository.searchPatients(dentistId, query);
  }
}
