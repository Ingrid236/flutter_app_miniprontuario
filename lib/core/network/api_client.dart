import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/secure_storage_service.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshQueue = [];

  ApiClient(this._secureStorage)
      : _dio = Dio(BaseOptions(
          // We use http://127.0.0.1:8080 to force IPv4 connection.
          // This avoids IPv6 resolution issues on physical Android devices when using adb reverse.
          // For Android physical devices and emulators, run:
          // adb reverse tcp:8080 tcp:8080
          baseUrl: 'http://127.0.0.1:8080',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) async {
        // Handle no connection or host lookup failure
        if (e.type == DioExceptionType.connectionError ||
            e.error is SocketException) {
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: 'Sem conexão — verifique sua internet',
              type: e.type,
            ),
          );
        }

        // Handle timeouts
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: 'Tempo limite esgotado. Tente novamente.',
              type: e.type,
            ),
          );
        }

        // Handle 401 Unauthorized for Refresh Token Rotation
        final response = e.response;
        final requestOptions = e.requestOptions;

        if (response != null &&
            response.statusCode == 401 &&
            !requestOptions.path.contains('/auth/refresh') &&
            !requestOptions.path.contains('/auth/login')) {
          
          if (_isRefreshing) {
            final completer = Completer<void>();
            _refreshQueue.add(completer);
            await completer.future;

            try {
              final retriedResponse = await _retryRequest(requestOptions);
              return handler.resolve(retriedResponse);
            } catch (err) {
              return handler.reject(DioException(
                requestOptions: requestOptions,
                error: err,
              ));
            }
          }

          _isRefreshing = true;

          try {
            final refreshToken = await _secureStorage.getRefreshToken();
            if (refreshToken == null) {
              await _secureStorage.clearSession();
              return handler.reject(e);
            }

            final refreshDio = Dio(BaseOptions(
              baseUrl: _dio.options.baseUrl,
            ));

            final refreshResponse = await refreshDio.post(
              '/auth/refresh',
              data: {'refreshToken': refreshToken},
            );

            if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
              final newAccessToken = refreshResponse.data['accessToken'];
              final newRefreshToken = refreshResponse.data['refreshToken'];

              await _secureStorage.saveTokens(newAccessToken, newRefreshToken);

              for (final completer in _refreshQueue) {
                completer.complete();
              }
              _refreshQueue.clear();
              _isRefreshing = false;

              final retriedResponse = await _retryRequest(requestOptions);
              return handler.resolve(retriedResponse);
            }
          } catch (refreshError) {
            await _secureStorage.clearSession();
            for (final completer in _refreshQueue) {
              completer.completeError(refreshError);
            }
            _refreshQueue.clear();
            _isRefreshing = false;

            return handler.reject(
              DioException(
                requestOptions: requestOptions,
                error: 'Sessão expirada. Faça login novamente.',
                response: response,
              ),
            );
          }
        }

        if (response != null && response.data is Map) {
          final message = response.data['message'] ?? response.data['error'] ?? 'Erro no servidor';
          return handler.reject(
            DioException(
              requestOptions: requestOptions,
              error: message,
              response: response,
            ),
          );
        }

        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final token = await _secureStorage.getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage);
});
