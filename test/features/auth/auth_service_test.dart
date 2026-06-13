import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_miniprontuario/core/utils/secure_storage_service.dart';
import 'package:flutter_app_miniprontuario/features/auth/data/auth_repository.dart';
import 'package:flutter_app_miniprontuario/features/auth/domain/auth_service.dart';
import 'package:flutter_app_miniprontuario/features/auth/domain/dentist.dart';

// Fake Auth Repository for testing
class FakeAuthRepository implements AuthRepository {
  final Map<String, Dentist> _dentists = {};
  String? _activeEmail;

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String cro,
    required String phone,
  }) async {
    if (_dentists.values.any((d) => d.email == email)) {
      throw Exception('Email already registered');
    }
    final dentist = Dentist(
      id: 'dentist-id-${_dentists.length}',
      name: name,
      email: email,
      cpf: cpf,
      cro: cro,
      phone: phone,
    );
    _dentists[dentist.id] = dentist;
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (password == 'wrongpassword') {
      throw Exception('Invalid credentials');
    }
    final dentist = _dentists.values.firstWhere(
      (d) => d.email == email,
      orElse: () => throw Exception('Invalid credentials'),
    );
    _activeEmail = email;
    return {
      'accessToken': 'dummy-access-token',
      'refreshToken': 'dummy-refresh-token',
      'user': {
        'id': dentist.id,
        'name': dentist.name,
        'email': dentist.email,
      }
    };
  }

  @override
  Future<Dentist?> getMe() async {
    if (_activeEmail == null) return null;
    return _dentists.values.firstWhere((d) => d.email == _activeEmail);
  }

  @override
  Future<void> logout(String refreshToken) async {
    _activeEmail = null;
  }
}

// Fake Secure Storage Service for testing
class FakeSecureStorageService implements SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<String> getOrCreateDatabaseKey() async {
    return _data['db_encryption_key'] ??= 'dummy-key';
  }

  @override
  Future<void> saveSession(String dentistId) async {
    _data['active_dentist_id'] = dentistId;
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    _data['access_token'] = accessToken;
    _data['refresh_token'] = refreshToken;
  }

  @override
  Future<String?> getSession() async {
    return _data['active_dentist_id'];
  }

  @override
  Future<String?> getAccessToken() async {
    return _data['access_token'];
  }

  @override
  Future<String?> getRefreshToken() async {
    return _data['refresh_token'];
  }

  @override
  Future<void> clearSession() async {
    _data.remove('active_dentist_id');
    _data.remove('access_token');
    _data.remove('refresh_token');
  }
}

void main() {
  late FakeAuthRepository authRepository;
  late FakeSecureStorageService secureStorage;
  late AuthService authService;

  setUp(() {
    authRepository = FakeAuthRepository();
    secureStorage = FakeSecureStorageService();
    authService = AuthService(authRepository, secureStorage);
  });

  group('AuthService Tests', () {
    test('register should create a dentist and save session', () async {
      final dentist = await authService.register(
        name: 'Dr. John Doe',
        email: 'john@example.com',
        password: 'password123',
        cpf: '123.456.789-00',
        cro: '12345-SP',
        phone: '(11) 99999-9999',
      );

      expect(dentist, isNotNull);
      expect(dentist!.name, 'Dr. John Doe');
      expect(dentist.email, 'john@example.com');
      expect(await secureStorage.getSession(), dentist.id);
    });

    test('register should fail if email already exists', () async {
      await authService.register(
        name: 'Dr. John Doe',
        email: 'john@example.com',
        password: 'password123',
        cpf: '123.456.789-00',
        cro: '12345-SP',
        phone: '(11) 99999-9999',
      );

      expect(
        () => authService.register(
          name: 'Another Dentist',
          email: 'john@example.com',
          password: 'password456',
          cpf: '987.654.321-11',
          cro: '54321-SP',
          phone: '(11) 88888-8888',
        ),
        throwsException,
      );
    });

    test(
      'login should succeed with valid credentials and save session',
      () async {
        await authService.register(
          name: 'Dr. John Doe',
          email: 'john@example.com',
          password: 'password123',
          cpf: '123.456.789-00',
          cro: '12345-SP',
          phone: '(11) 99999-9999',
        );

        await secureStorage.clearSession();

        final dentist = await authService.login(
          email: 'john@example.com',
          password: 'password123',
        );

        expect(dentist, isNotNull);
        expect(dentist!.email, 'john@example.com');
        expect(await secureStorage.getSession(), dentist.id);
      },
    );

    test('login should fail with invalid credentials', () async {
      await authService.register(
        name: 'Dr. John Doe',
        email: 'john@example.com',
        password: 'password123',
        cpf: '123.456.789-00',
        cro: '12345-SP',
        phone: '(11) 99999-9999',
      );

      expect(
        () => authService.login(
          email: 'john@example.com',
          password: 'wrongpassword',
        ),
        throwsException,
      );
    });

    test('logout should clear secure session', () async {
      await secureStorage.saveSession('some-id');
      await secureStorage.saveTokens('token', 'refresh');
      expect(await secureStorage.getSession(), 'some-id');

      await authService.logout();

      expect(await secureStorage.getSession(), isNull);
      expect(await secureStorage.getAccessToken(), isNull);
    });

    test(
      'getCurrentDentist should return dentist if session is active',
      () async {
        final dentist = await authService.register(
          name: 'Dr. John Doe',
          email: 'john@example.com',
          password: 'password123',
          cpf: '123.456.789-00',
          cro: '12345-SP',
          phone: '(11) 99999-9999',
        );

        final current = await authService.getCurrentDentist();
        expect(current, isNotNull);
        expect(current!.id, dentist!.id);
      },
    );

    test(
      'getCurrentDentist should return null if session is inactive',
      () async {
        final current = await authService.getCurrentDentist();
        expect(current, isNull);
      },
    );
  });
}
