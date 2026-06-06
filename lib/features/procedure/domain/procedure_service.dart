import 'package:uuid/uuid.dart';
import '../../../core/utils/secure_storage_service.dart';
import '../../patient/data/patient_repository.dart';
import '../data/procedure_repository.dart';
import 'procedure.dart';

class ProcedureService {
  final ProcedureRepository _procedureRepository;
  final PatientRepository _patientRepository;
  final SecureStorageService _secureStorage;
  static const _uuid = Uuid();

  ProcedureService(
    this._procedureRepository,
    this._patientRepository,
    this._secureStorage,
  );

  Future<String> _getRequiredSession() async {
    final dentistId = await _secureStorage.getSession();
    if (dentistId == null) {
      throw Exception(
        'Sessão profissional não encontrada. Faça login novamente.',
      );
    }
    return dentistId;
  }

  Future<void> _validatePatientOwnership(String dentistId, String patientId) async {
    final patient = await _patientRepository.getPatientById(patientId);
    if (patient == null || patient.dentistId != dentistId) {
      throw Exception('Acesso negado: o paciente informado não pertence ao seu prontuário ou não existe.');
    }
  }

  Future<Procedure> createProcedure({
    required String patientId,
    required String type,
    required DateTime date,
    String? tooth,
    String? observations,
    required String status,
    double? cost,
  }) async {
    final dentistId = await _getRequiredSession();
    await _validatePatientOwnership(dentistId, patientId);

    final id = _uuid.v4();
    final procedure = Procedure(
      id: id,
      patientId: patientId,
      type: type,
      date: date,
      tooth: tooth,
      observations: observations,
      status: status,
      cost: cost,
      createdAt: DateTime.now(),
    );

    await _procedureRepository.createProcedure(procedure);
    return procedure;
  }

  Future<Procedure> updateProcedure({
    required String id,
    required String patientId,
    required String type,
    required DateTime date,
    String? tooth,
    String? observations,
    required String status,
    double? cost,
  }) async {
    final dentistId = await _getRequiredSession();
    await _validatePatientOwnership(dentistId, patientId);

    final original = await _procedureRepository.getProcedureById(id);
    if (original == null || original.patientId != patientId) {
      throw Exception('Procedimento não encontrado.');
    }

    final updated = original.copyWith(
      type: type,
      date: date,
      tooth: tooth,
      observations: observations,
      status: status,
      cost: cost,
    );

    await _procedureRepository.updateProcedure(updated);
    return updated;
  }

  Future<void> deleteProcedure(String id) async {
    final dentistId = await _getRequiredSession();
    
    final procedure = await _procedureRepository.getProcedureById(id);
    if (procedure == null) {
      throw Exception('Procedimento não encontrado.');
    }
    
    await _validatePatientOwnership(dentistId, procedure.patientId);
    await _procedureRepository.deleteProcedure(id);
  }

  Future<Procedure?> getProcedure(String id) async {
    final dentistId = await _getRequiredSession();
    
    final procedure = await _procedureRepository.getProcedureById(id);
    if (procedure == null) return null;
    
    await _validatePatientOwnership(dentistId, procedure.patientId);
    return procedure;
  }

  Future<List<Procedure>> getProceduresForPatient(String patientId) async {
    final dentistId = await _getRequiredSession();
    await _validatePatientOwnership(dentistId, patientId);
    
    return await _procedureRepository.getProceduresForPatient(patientId);
  }
}
