import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Tempo de conexão esgotado. Tente novamente.');
      case DioExceptionType.connectionError:
        return ApiException('Sem conexão — verifique sua internet.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        String apiMessage = '';
        if (data is Map<String, dynamic>) {
          if (data['message'] != null) {
            apiMessage = data['message'];
          } else if (data['errors'] != null && data['errors'] is Map) {
            final errorsMap = data['errors'] as Map;
            apiMessage = errorsMap.values.join('\n');
          }
        }

        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // 401 Unauthorized is handled specifically in auth layers or interceptors
            if (statusCode == 401) {
              return ApiException('Sessão expirada ou credenciais inválidas.', statusCode);
            }
            if (statusCode == 403) {
              return ApiException('Acesso negado.', statusCode);
            }
            return ApiException(
              apiMessage.isNotEmpty ? apiMessage : 'Erro na requisição. Verifique os dados enviados.',
              statusCode,
            );
          } else if (statusCode >= 500) {
            return ApiException('Erro interno do servidor. Tente novamente mais tarde.', statusCode);
          }
        }
        return ApiException('Resposta inesperada do servidor.');
      case DioExceptionType.cancel:
        return ApiException('A requisição foi cancelada.');
      default:
        final detail = error.message ?? error.error?.toString() ?? '';
        return ApiException(detail.isNotEmpty 
            ? 'Ocorreu um erro desconhecido: $detail' 
            : 'Ocorreu um erro desconhecido.');
    }
  }
}
