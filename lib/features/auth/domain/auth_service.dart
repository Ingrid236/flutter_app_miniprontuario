import '../../../core/utils/secure_storage_service.dart';
import '../data/auth_repository.dart';
import 'dentist.dart';

class AuthService {
  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage;

  AuthService(this._authRepository, this._secureStorage);

  Future<Dentist?> register({
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

    return await login(email: email, password: password);
  }

  Future<Dentist?> login({
    required String email,
    required String password,
  }) async {
    final response = await _authRepository.login(email, password);
    final accessToken = response['accessToken'] as String;
    final refreshToken = response['refreshToken'] as String;
    final dentistId = response['user']['id'] as String;

    await _secureStorage.saveTokens(accessToken, refreshToken);
    await _secureStorage.saveSession(dentistId);

    return await _authRepository.getMe();
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null) {
        await _authRepository.logout(refreshToken);
      }
    } catch (_) {
      // Ignore and proceed to local logout in case of server failure/revocation
    } finally {
      await _secureStorage.clearSession();
    }
  }

  Future<Dentist?> getCurrentDentist() async {
    final dentistId = await _secureStorage.getSession();
    if (dentistId == null) return null;
    return await _authRepository.getMe();
  }
}
