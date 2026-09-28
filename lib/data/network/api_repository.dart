import 'package:dio/dio.dart';

import '../../core/result/result.dart';
import 'api_routes.dart';
import 'api_service.dart';

class ApiRepository {
  static const streamSilence = Duration(seconds: 30);

  ApiRepository(
    this._api, {
    ApiService? history,
  }) : _history = history;

  final ApiService _api;
  final ApiService? _history;

  bool get hasHistory => _history != null;

  Future<Result<Response<ResponseBody>>> streamGeminiGenerateContent({
    required String model,
    required Map<String, dynamic> body,
    CancelToken? cancelToken,
  }) {
    return _api.post<ResponseBody>(
      ApiRoutes.geminiStreamGenerateContent(model),
      queryParameters: const {'alt': 'sse'},
      data: body,
      options: Options(
        responseType: ResponseType.stream,
        receiveTimeout: streamSilence,
        headers: const {
          Headers.acceptHeader: 'text/event-stream',
          Headers.contentTypeHeader: Headers.jsonContentType,
        },
      ),
      cancelToken: cancelToken,
    );
  }

  Future<Result<Response<Map<String, dynamic>>>> generateGeminiContent({
    required String model,
    required Map<String, dynamic> body,
    CancelToken? cancelToken,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.geminiGenerateContent(model),
      data: body,
      options: Options(
        headers: const {
          Headers.acceptHeader: Headers.jsonContentType,
          Headers.contentTypeHeader: Headers.jsonContentType,
        },
      ),
      cancelToken: cancelToken,
    );
  }

  Future<Result<Map<String, dynamic>>> fetchHistory(String installId) async {
    final history = _history;
    if (history == null || installId.isEmpty) return const Success({});
    final response = await history.get<Map<String, dynamic>>(
      ApiRoutes.historyUser(installId),
    );
    return response.when(
      success: (value) => Success(value.data ?? {}),
      failure: (error, stackTrace) => Failure(error, stackTrace),
    );
  }

  Future<Result<bool>> putHistoryChat({
    required String installId,
    required String chatId,
    required Map<String, dynamic> body,
  }) async {
    final history = _history;
    if (history == null || installId.isEmpty) return const Success(false);
    final response = await history.put<void>(
      ApiRoutes.historyChat(installId, chatId),
      data: body,
    );
    return response.when(
      success: (_) => const Success(true),
      failure: (error, stackTrace) => Failure(error, stackTrace),
    );
  }

  Future<Result<bool>> deleteHistoryChat({
    required String installId,
    required String chatId,
    String? opId,
  }) async {
    final history = _history;
    if (history == null || installId.isEmpty) return const Success(false);
    final response = await history.delete<void>(
      ApiRoutes.historyChat(installId, chatId),
      queryParameters: {
        if (opId != null && opId.isNotEmpty) 'opId': opId,
      },
    );
    return response.when(
      success: (_) => const Success(true),
      failure: (error, stackTrace) => Failure(error, stackTrace),
    );
  }
}
