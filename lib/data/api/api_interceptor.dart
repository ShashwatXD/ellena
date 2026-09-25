import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiKeyInterceptor extends Interceptor {
  ApiKeyInterceptor(this.apiKey);

  final String apiKey;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final key = apiKey.trim();
    if (key.isNotEmpty) {
      options.queryParameters['key'] = key;
    }
    handler.next(options);
  }
}

class ApiErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode && err.type != DioExceptionType.cancel) {
      final status = err.response?.statusCode;
      debugPrint(
        'API ${err.requestOptions.method} '
        '${_redact(err.requestOptions.uri)} '
        '${status ?? err.type.name}',
      );
    }
    handler.next(err);
  }

  static String _redact(Uri uri) {
    if (!uri.queryParameters.containsKey('key')) return uri.toString();
    final params = Map<String, String>.from(uri.queryParameters)
      ..['key'] = '***';
    return uri.replace(queryParameters: params).toString();
  }
}
