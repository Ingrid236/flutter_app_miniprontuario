import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/dentist.dart';

abstract class AuthRepository {
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String cro,
    required String phone,
  });

  Future<Map<String, dynamic>> login(String email, String password);
  Future<Dentist?> getMe();
  Future<void> logout(String refreshToken);
}

class RestAuthRepository implements AuthRepository {
  final ApiClient _apiClient;

  RestAuthRepository(this._apiClient);

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String cro,
    required String phone,
  }) async {
    await _apiClient.dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'cpf': cpf,
      'cro': cro,
      'phone': phone,
    });
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Dentist?> getMe() async {
    try {
      final response = await _apiClient.dio.get('/auth/me');
      if (response.data != null) {
        return Dentist.fromMap(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _apiClient.dio.post('/auth/logout', data: {
      'refreshToken': refreshToken,
    });
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RestAuthRepository(apiClient);
});
