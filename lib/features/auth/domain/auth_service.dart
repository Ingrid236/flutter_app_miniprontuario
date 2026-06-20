import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/secure_storage_service.dart';
import '../data/auth_repository.dart';
import 'dentist.dart';

class AuthService {
  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage;

  AuthService(this._authRepository, this._secureStorage);

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String cro,
    required String phone,
  }) async {
    await _authRepository.register(
      name: name,
      email: email,
      password: password,
      cpf: cpf,
      cro: cro,
      phone: phone,
    );
  }

  Future<Dentist> login({
    required String email,
    required String password,
  }) async {
    // The repository handles token persistence on successful login
    return await _authRepository.login(email: email, password: password);
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _authRepository.logout(refreshToken);
      }
    } catch (_) {
      // Ignore errors so local tokens are still cleared in case of network issues
    } finally {
      await _secureStorage.clearTokens();
    }
  }

  Future<Dentist?> getCurrentDentist() async {
    final hasSession = await _secureStorage.hasSession();
    if (!hasSession) return null;
    try {
      return await _authRepository.getMe();
    } catch (_) {
      // Token might be expired and refresh failed — treat as logged out
      await _secureStorage.clearTokens();
      return null;
    }
  }
}

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthService(repository, secureStorage);
});

