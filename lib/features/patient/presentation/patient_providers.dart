import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/patient.dart';
import '../domain/patient_service.dart';

// Notifier for managing patient lists and queries using AsyncNotifier
class PatientsListNotifier extends AsyncNotifier<List<Patient>> {
  @override
  Future<List<Patient>> build() async {
    final service = ref.watch(patientServiceProvider);
    return await service.getPatients();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(patientServiceProvider);
      return await service.getPatients();
    });
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      await refresh();
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(patientServiceProvider);
      return await service.search(query);
    });
  }
}

// Global provider for the patient list
final patientsListProvider =
    AsyncNotifierProvider<PatientsListNotifier, List<Patient>>(() {
      return PatientsListNotifier();
    });

// Global provider for a specific patient's details
final patientDetailProvider = FutureProvider.family
    .autoDispose<Patient?, String>((ref, id) async {
      final service = ref.watch(patientServiceProvider);
      return await service.getPatient(id);
    });

// Global provider for the AI generated clinical risk report
final patientAiAnalysisProvider = FutureProvider.family
    .autoDispose<String, String>((ref, id) async {
      final apiClient = ref.watch(apiClientProvider);
      final response = await apiClient.dio.post('/ai/analyze-patient/$id');
      return response.data['analysis'] as String;
    });

// Controller notifier for creating, updating, and deleting patients
class PatientController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<bool> createPatient({
    required String name,
    required DateTime birthDate,
    required String cpf,
    String? phone,
    String? allergies,
    String? systemicDiseases,
  }) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(patientServiceProvider);
      await service.createPatient(
        name: name,
        birthDate: birthDate,
        cpf: cpf,
        phone: phone,
        allergies: allergies,
        systemicDiseases: systemicDiseases,
      );
      ref.invalidate(patientsListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> updatePatient({
    required String id,
    required String name,
    required DateTime birthDate,
    required String cpf,
    String? phone,
    String? allergies,
    String? systemicDiseases,
  }) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(patientServiceProvider);
      await service.updatePatient(
        id: id,
        name: name,
        birthDate: birthDate,
        cpf: cpf,
        phone: phone,
        allergies: allergies,
        systemicDiseases: systemicDiseases,
      );
      ref.invalidate(patientsListProvider);
      ref.invalidate(patientDetailProvider(id));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> deletePatient(String id) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(patientServiceProvider);
      await service.deletePatient(id);
      ref.invalidate(patientsListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

// Provider for the patient form controller
final patientControllerProvider =
    NotifierProvider<PatientController, AsyncValue<void>>(() {
      return PatientController();
    });



