import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'api_client.dart';

class IaService {
  final ApiClient _api;

  IaService(this._api);

  /// Envia um arquivo de áudio para a IA e retorna o texto transcrito.
  Future<String> transcreverAudio(File audioFile) async {
    // Forçamos o nome do arquivo com a extensão .m4a para o backend entender o formato corretamente.
    final fileName = 'gravacao.m4a';

    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        audioFile.path,
        filename: fileName,
        contentType: MediaType('audio', 'm4a'),
      ),
    });

    final response = await _api.postMultipart(
      '/api/ia/transcrever-audio',
      formData,
    );

    return response;
  }
}

final iaServiceProvider = Provider<IaService>((ref) {
  final api = ref.watch(apiClientProvider);
  return IaService(api);
});
