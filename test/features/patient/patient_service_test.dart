import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_miniprontuario/features/patient/data/patient_repository.dart';
import 'package:flutter_app_miniprontuario/features/patient/domain/patient.dart';
import 'package:flutter_app_miniprontuario/features/patient/domain/patient_service.dart';
import '../auth/auth_service_test.dart'; // To reuse FakeSecureStorageService

class FakePatientRepository implements PatientRepository {
  final Map<String, Patient> _patients = {};

  @override
  Future<void> createPatient(Patient patient) async {
    _patients[patient.id] = patient;
  }

  @override
  Future<void> updatePatient(Patient patient) async {
    _patients[patient.id] = patient;
  }

  @override
  Future<void> deletePatient(String id) async {
    _patients.remove(id);
  }

  @override
  Future<Patient?> getPatientById(String id) async {
    return _patients[id];
  }

  @override
  Future<List<Patient>> getPatientsForDentist(String dentistId) async {
    return _patients.values.where((p) => p.dentistId == dentistId).toList();
  }

  @override
  Future<Patient?> getPatientByCpf(String dentistId, String cpf) async {
    try {
      return _patients.values.firstWhere(
        (p) => p.dentistId == dentistId && p.cpf == cpf,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Patient>> searchPatients(String dentistId, String query) async {
    final cleanQuery = query.toLowerCase();
    return _patients.values
        .where(
          (p) =>
              p.dentistId == dentistId &&
              (p.name.toLowerCase().contains(cleanQuery) ||
                  p.cpf.contains(cleanQuery)),
        )
        .toList();
  }
}

void main() {
  late FakePatientRepository patientRepository;
  late FakeSecureStorageService secureStorage;
  late PatientService patientService;
  const String dentistId = 'dentist-123';

  setUp(() async {
    patientRepository = FakePatientRepository();
    secureStorage = FakeSecureStorageService();
    patientService = PatientService(patientRepository, secureStorage);

    // Set active dentist session
    await secureStorage.saveSession(dentistId);
  });

  group('PatientService Tests', () {
    test('createPatient should succeed and save patient details', () async {
      final patient = await patientService.createPatient(
        name: 'Jane Doe',
        birthDate: DateTime(1990, 5, 15),
        cpf: '111.111.111-11',
        phone: '(11) 98888-8888',
        allergies: 'Penicilina',
      );

      expect(patient, isNotNull);
      expect(patient.id, isNotEmpty);
      expect(patient.dentistId, dentistId);
      expect(patient.name, 'Jane Doe');
      expect(patient.allergies, 'Penicilina');

      final saved = await patientRepository.getPatientById(patient.id);
      expect(saved, isNotNull);
      expect(saved!.name, 'Jane Doe');
    });

    test('createPatient should fail if no session is active', () async {
      await secureStorage.clearSession();

      expect(
        () => patientService.createPatient(
          name: 'Jane Doe',
          birthDate: DateTime(1990, 5, 15),
          cpf: '111.111.111-11',
          phone: '(11) 98888-8888',
        ),
        throwsException,
      );
    });

    test(
      'createPatient should fail if CPF already exists for this dentist',
      () async {
        await patientService.createPatient(
          name: 'Jane Doe',
          birthDate: DateTime(1990, 5, 15),
          cpf: '111.111.111-11',
          phone: '(11) 98888-8888',
        );

        expect(
          () => patientService.createPatient(
            name: 'Another Jane',
            birthDate: DateTime(1985, 1, 10),
            cpf: '111.111.111-11',
            phone: '(11) 97777-7777',
          ),
          throwsException,
        );
      },
    );

    test('updatePatient should update fields and update timestamp', () async {
      final patient = await patientService.createPatient(
        name: 'Jane Doe',
        birthDate: DateTime(1990, 5, 15),
        cpf: '111.111.111-11',
        phone: '(11) 98888-8888',
      );

      final updated = await patientService.updatePatient(
        id: patient.id,
        name: 'Jane Smith',
        birthDate: DateTime(1990, 5, 15),
        cpf: '111.111.111-11',
        phone: '(11) 99999-9999',
        allergies: 'Pólen',
      );

      expect(updated.name, 'Jane Smith');
      expect(updated.phone, '(11) 99999-9999');
      expect(updated.allergies, 'Pólen');
      expect(
        updated.updatedAt.isAfter(patient.createdAt) ||
            updated.updatedAt.isAtSameMomentAs(patient.createdAt),
        true,
      );
    });

    test(
      'updatePatient should fail if CPF is changed to an existing patient\'s CPF',
      () async {
        await patientService.createPatient(
          name: 'Jane Doe',
          birthDate: DateTime(1990, 5, 15),
          cpf: '111.111.111-11',
          phone: '(11) 98888-8888',
        );

        final p2 = await patientService.createPatient(
          name: 'John Smith',
          birthDate: DateTime(1988, 2, 20),
          cpf: '222.222.222-22',
          phone: '(11) 97777-7777',
        );

        expect(
          () => patientService.updatePatient(
            id: p2.id,
            name: 'John Smith',
            birthDate: DateTime(1988, 2, 20),
            cpf: '111.111.111-11', // changing p2's CPF to p1's CPF (conflict!)
            phone: '(11) 97777-7777',
          ),
          throwsException,
        );
      },
    );

    test('deletePatient should remove patient from repository', () async {
      final patient = await patientService.createPatient(
        name: 'Jane Doe',
        birthDate: DateTime(1990, 5, 15),
        cpf: '111.111.111-11',
        phone: '(11) 98888-8888',
      );

      expect(await patientRepository.getPatientById(patient.id), isNotNull);

      await patientService.deletePatient(patient.id);

      expect(await patientRepository.getPatientById(patient.id), isNull);
    });

    test(
      'getPatients should retrieve patients for active dentist only',
      () async {
        await patientService.createPatient(
          name: 'Jane Doe',
          birthDate: DateTime(1990, 5, 15),
          cpf: '111.111.111-11',
          phone: '(11) 98888-8888',
        );

        final list = await patientService.getPatients();
        expect(list.length, 1);
        expect(list.first.name, 'Jane Doe');
      },
    );

    test('search should match by name or CPF', () async {
      await patientService.createPatient(
        name: 'Jane Doe',
        birthDate: DateTime(1990, 5, 15),
        cpf: '111.111.111-11',
        phone: '(11) 98888-8888',
      );

      await patientService.createPatient(
        name: 'Bob Marley',
        birthDate: DateTime(1945, 2, 6),
        cpf: '222.222.222-22',
        phone: '(11) 97777-7777',
      );

      final matchName = await patientService.search('marley');
      expect(matchName.length, 1);
      expect(matchName.first.name, 'Bob Marley');

      final matchCpf = await patientService.search('111');
      expect(matchCpf.length, 1);
      expect(matchCpf.first.name, 'Jane Doe');
    });
  });
}
