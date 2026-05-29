import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/secure_storage_service.dart';
import '../data/auth_repository.dart';
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

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthService(repository, secureStorage);
});

// A simple notifier/status provider that checks the session on startup.
final sessionCheckProvider = FutureProvider<String?>((ref) async {
  final secureStorage = ref.read(secureStorageProvider);
  final dentistId = await secureStorage.getSession();
  if (dentistId != null) {
    ref.read(activeDentistIdProvider.notifier).setSession(dentistId);
  }
  return dentistId;
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
      if (dentist != null) {
        ref.read(activeDentistIdProvider.notifier).setSession(dentist.id);
        state = const AsyncValue.data(null);
        return true;
      } else {
        state = AsyncValue.error(
          Exception('E-mail ou senha incorretos.'),
          StackTrace.current,
        );
        return false;
      }
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
      final dentist = await authService.register(
        name: name,
        email: email,
        password: password,
        cpf: cpf,
        cro: cro,
        phone: phone,
      );
      if (dentist != null) {
        ref.read(activeDentistIdProvider.notifier).setSession(dentist.id);
        state = const AsyncValue.data(null);
        return true;
      } else {
        state = AsyncValue.error(
          Exception('Erro ao criar conta profissional.'),
          StackTrace.current,
        );
        return false;
      }
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
