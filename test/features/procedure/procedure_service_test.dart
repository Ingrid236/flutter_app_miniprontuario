import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_miniprontuario/features/procedure/data/procedure_repository.dart';
import 'package:flutter_app_miniprontuario/features/procedure/domain/procedure.dart';
import 'package:flutter_app_miniprontuario/features/procedure/domain/procedure_service.dart';
import 'package:flutter_app_miniprontuario/features/patient/domain/patient.dart';
import '../auth/auth_service_test.dart'; // To reuse FakeSecureStorageService
import '../patient/patient_service_test.dart';

class FakeProcedureRepository implements ProcedureRepository {
  final Map<String, Procedure> _procedures = {};

  @override
  Future<void> createProcedure(Procedure procedure) async {
    _procedures[procedure.id] = procedure;
  }

  @override
  Future<void> updateProcedure(Procedure procedure) async {
    _procedures[procedure.id] = procedure;
  }

  @override
  Future<void> deleteProcedure(String id) async {
    _procedures.remove(id);
  }

  @override
  Future<Procedure?> getProcedureById(String id) async {
    return _procedures[id];
  }

  @override
  Future<List<Procedure>> getProceduresForPatient(String patientId) async {
    final list = _procedures.values
        .where((p) => p.patientId == patientId)
        .toList();
    // Sort chronologically by date
    list.sort((a, b) => b.date.compareTo(a.date)); // Descending chronological
    return list;
  }
}

void main() {
  late FakeProcedureRepository procedureRepository;
  late FakePatientRepository patientRepository;
  late FakeSecureStorageService secureStorage;
  late ProcedureService procedureService;
  const String dentistId = 'dentist-123';
  const String patientId = 'patient-456';

  setUp(() async {
    procedureRepository = FakeProcedureRepository();
    patientRepository = FakePatientRepository();
    secureStorage = FakeSecureStorageService();
    procedureService = ProcedureService(
      procedureRepository,
      patientRepository,
      secureStorage,
    );

    // Set active session
    await secureStorage.saveSession(dentistId);

    // Seed patient to satisfy dentist-patient ownership check
    await patientRepository.createPatient(Patient(
      id: patientId,
      dentistId: dentistId,
      name: 'Jane Doe',
      birthDate: DateTime(1990, 5, 15),
      cpf: '111.111.111-11',
      phone: '(11) 98888-8888',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  });

  group('ProcedureService Tests', () {
    test('createProcedure should succeed and save details', () async {
      final procedure = await procedureService.createProcedure(
        patientId: patientId,
        type: 'Limpeza Dental',
        date: DateTime(2026, 5, 29),
        tooth: '18',
        observations: 'Paciente colaborativo',
        status: 'Completed',
        cost: 150.0,
      );

      expect(procedure, isNotNull);
      expect(procedure.id, isNotEmpty);
      expect(procedure.patientId, patientId);
      expect(procedure.type, 'Limpeza Dental');
      expect(procedure.cost, 150.0);

      final saved = await procedureRepository.getProcedureById(procedure.id);
      expect(saved, isNotNull);
      expect(saved!.type, 'Limpeza Dental');
    });

    test('createProcedure should fail if no active session', () async {
      await secureStorage.clearSession();

      expect(
        () => procedureService.createProcedure(
          patientId: patientId,
          type: 'Limpeza Dental',
          date: DateTime(2026, 5, 29),
          status: 'Completed',
        ),
        throwsException,
      );
    });

    test('updateProcedure should update attributes successfully', () async {
      final procedure = await procedureService.createProcedure(
        patientId: patientId,
        type: 'Limpeza Dental',
        date: DateTime(2026, 5, 29),
        status: 'Planned',
      );

      final updated = await procedureService.updateProcedure(
        id: procedure.id,
        patientId: patientId,
        type: 'Restauração Resinada',
        date: DateTime(2026, 5, 29),
        tooth: '24',
        observations: 'Mudança de plano para restauração',
        status: 'Completed',
        cost: 200.0,
      );

      expect(updated.type, 'Restauração Resinada');
      expect(updated.tooth, '24');
      expect(updated.status, 'Completed');
      expect(updated.cost, 200.0);
    });

    test('deleteProcedure should remove procedure from repository', () async {
      final procedure = await procedureService.createProcedure(
        patientId: patientId,
        type: 'Limpeza Dental',
        date: DateTime(2026, 5, 29),
        status: 'Completed',
      );

      expect(
        await procedureRepository.getProcedureById(procedure.id),
        isNotNull,
      );

      await procedureService.deleteProcedure(procedure.id);

      expect(await procedureRepository.getProcedureById(procedure.id), isNull);
    });

    test(
      'getProceduresForPatient should return patient procedures in reverse chronological order',
      () async {
        // Create older procedure
        await procedureService.createProcedure(
          patientId: patientId,
          type: 'Limpeza',
          date: DateTime(2026, 5, 10),
          status: 'Completed',
        );

        // Create newer procedure
        await procedureService.createProcedure(
          patientId: patientId,
          type: 'Extração',
          date: DateTime(2026, 5, 20),
          status: 'Completed',
        );

        final list = await procedureService.getProceduresForPatient(patientId);
        expect(list.length, 2);
        expect(list.first.type, 'Extração'); // May 20 is newer than May 10
        expect(list.last.type, 'Limpeza');
      },
    );
  });
}
