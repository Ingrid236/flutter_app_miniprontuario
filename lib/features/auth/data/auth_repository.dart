import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/utils/secure_storage_service.dart';
import '../domain/dentist.dart';

abstract class AuthRepository {
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String cro,
    String? phone,
  });

  Future<Dentist> login({
    required String email,
    required String password,
  });

  Future<Dentist> getMe();

  Future<void> logout(String refreshToken);
}

class RemoteAuthRepository implements AuthRepository {
  final ApiClient _api;
  final SecureStorageService _storage;

  RemoteAuthRepository(this._api, this._storage);

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String cro,
    String? phone,
  }) async {
    await _api.postPublic(ApiConstants.register, {
      'name': name,
      'email': email,
      'password': password,
      'cpf': cpf,
      'cro': cro,
      if (phone != null) 'phone': phone,
    });
  }

  @override
  Future<Dentist> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.postPublic(ApiConstants.login, {
      'email': email,
      'password': password,
    });

    // Persist tokens
    await _storage.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String? ?? '', 
    );

    // Cache dentist ID from login response
    final user = data['user'] as Map<String, dynamic>;
    await _storage.saveDentistId(user['id'] as String);

    return Dentist.fromJson(user);
  }

  @override
  Future<Dentist> getMe() async {
    final data = await _api.get(ApiConstants.me);
    return Dentist.fromJson(data);
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _api.post(ApiConstants.logout, {
      'refreshToken': refreshToken,
    });
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return RemoteAuthRepository(api, storage);
});

