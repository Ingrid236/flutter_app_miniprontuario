import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/secure_storage_service.dart';
import '../../patient/presentation/patient_providers.dart';
import '../domain/auth_service.dart';
import '../domain/dentist.dart';

// Notifier class for active dentist ID
class ActiveDentistIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void setSession(String? dentistId) {
    state = dentistId;
  }
}

// Holds the currently logged in dentist's ID. Null if unauthenticated.
final activeDentistIdProvider =
    NotifierProvider<ActiveDentistIdNotifier, String?>(() {
      return ActiveDentistIdNotifier();
    });

// Session check on startup — checks if access token exists in secure storage.
final sessionCheckProvider = FutureProvider<bool>((ref) async {
  final secureStorage = ref.read(secureStorageProvider);
  final authService = ref.read(authServiceProvider);

  final hasToken = await secureStorage.hasSession();
  if (hasToken) {
    // Validate token by calling /auth/me (triggers refresh if needed)
    final dentist = await authService.getCurrentDentist();
    if (dentist != null) {
      await secureStorage.saveDentistId(dentist.id);
      ref.read(activeDentistIdProvider.notifier).setSession(dentist.id);
      return true;
    }
  }
  return false;
});

// Provider for the active dentist object
final currentDentistProvider = FutureProvider<Dentist?>((ref) async {
  final activeId = ref.watch(activeDentistIdProvider);
  if (activeId == null) return null;
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentDentist();
});

// Auth Controller to manage registration, login and logout UI states using Notifier
class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final dentist = await authService.login(email: email, password: password);
      ref.read(activeDentistIdProvider.notifier).setSession(dentist.id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String cro,
    required String phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      // Step 1: Register account
      await authService.register(
        name: name,
        email: email,
        password: password,
        cpf: cpf,
        cro: cro,
        phone: phone,
      );
      // Step 2: Auto-login after registration
      final dentist = await authService.login(email: email, password: password);
      ref.read(activeDentistIdProvider.notifier).setSession(dentist.id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      await authService.logout();
      ref.read(activeDentistIdProvider.notifier).setSession(null);
      ref.invalidate(patientsListProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(() {
      return AuthController();
    });

