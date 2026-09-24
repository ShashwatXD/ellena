import 'package:dio/dio.dart';

import '../../core/result/result.dart';
import 'api_routes.dart';
import 'api_service.dart';

class ApiRepository {
  ApiRepository(this._api);

  final ApiService _api;

  Future<Result<Response<ResponseBody>>> streamGeminiGenerateContent({
    required String model,
    required String apiKey,
    required Map<String, dynamic> body,
    CancelToken? cancelToken,
  }) {
    return _api.post<ResponseBody>(
      ApiRoutes.geminiStreamGenerateContent(model),
      queryParameters: {
        'alt': 'sse',
        'key': apiKey,
      },
      data: body,
      options: Options(
        responseType: ResponseType.stream,
        receiveTimeout: Duration.zero,
        headers: const {
          Headers.acceptHeader: 'text/event-stream',
          Headers.contentTypeHeader: Headers.jsonContentType,
        },
      ),
      cancelToken: cancelToken,
    );
  }
}
