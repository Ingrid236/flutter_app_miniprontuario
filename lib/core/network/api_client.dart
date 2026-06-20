import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/secure_storage_service.dart';
import 'api_constants.dart';
import 'api_exceptions.dart';
export 'api_exceptions.dart';

/// A centralized HTTP client using Dio that:
/// - Automatically injects the Bearer token into every request.
/// - Automatically refreshes the access token on 401 responses and retries.
/// - Transforms errors into friendly ApiExceptions.
class ApiClient {
  final SecureStorageService _storage;
  late final Dio _dio;

  ApiClient(this._storage, [Dio? dioOverride]) {
    _dio = dioOverride ??
        Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Retry logic for Timeouts
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout || 
            e.type == DioExceptionType.sendTimeout) {
          
          final int retries = e.requestOptions.extra['retries'] ?? 0;
          if (retries < 3) {
            // Attempt retry up to 3 times
            e.requestOptions.extra['retries'] = retries + 1;
            try {
              // Wait 1 second before retrying
              await Future.delayed(const Duration(seconds: 1));
              final response = await _dio.request(
                e.requestOptions.path,
                options: Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                ),
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
              );
              return handler.resolve(response);
            } catch (retryError) {
              return handler.next(retryError is DioException ? retryError : e);
            }
          }
        }

        // If 401 Unauthorized, try to refresh token
        if (e.response?.statusCode == 401) {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            // Retry the original request
            try {
              final newToken = await _storage.getAccessToken();
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              
              final response = await _dio.request(
                e.requestOptions.path,
                options: Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                ),
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
              );
              return handler.resolve(response);
            } catch (retryError) {
              return handler.next(
                retryError is DioException ? retryError : e,
              );
            }
          } else {
            // Force logout / Clear session if refresh failed
            await _storage.clearTokens();
          }
        }
        return handler.next(e);
      },
    ));
  }

  // ─── Public helpers ───────────────────────────────────────────────

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _dio.get(path);
      return _extractDataMap(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<dynamic>> getList(String path) async {
    try {
      final response = await _dio.get(path);
      return _extractDataList(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(path, data: body);
      return _extractDataMap(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<String> postMultipart(
      String path, FormData formData) async {
    try {
      final response = await _dio.post(
        path, 
        data: formData,
        options: Options(responseType: ResponseType.plain),
      );
      if (response.data == null) return '';
      return response.data.toString();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> put(
      String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.put(path, data: body);
      return _extractDataMap(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Public POST without auth headers (specifically used before interceptor handles it, though interceptor is global).
  /// For login/register/refresh, the server will ignore or override auth headers if not required.
  Future<Map<String, dynamic>> postPublic(
      String path, Map<String, dynamic> body) async {
    try {
      // Create a fresh Dio instance to avoid interceptor loop during refresh/login
      final freshDio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ));
      final response = await freshDio.post(path, data: body);
      return _extractDataMap(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ─── Internal helpers ─────────────────────────────────────────────

  Future<bool> _tryRefresh() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      // Use fresh Dio to avoid infinite 401 loops
      final freshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await freshDio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.saveTokens(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  Map<String, dynamic> _extractDataMap(Response response) {
    if (response.data == null || response.statusCode == 204 || response.data.toString().isEmpty) {
      return {};
    }
    if (response.data is String) {
      return {}; // Handle empty strings correctly
    }
    return response.data as Map<String, dynamic>;
  }

  List<dynamic> _extractDataList(Response response) {
    if (response.data == null || response.statusCode == 204 || response.data.toString().isEmpty) {
      return [];
    }
    return response.data as List<dynamic>;
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});
