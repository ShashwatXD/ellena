import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';

class ApiInterceptor extends Interceptor {
  bool get _log => AppConfig.current.isDev;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_log) {
      debugPrint('API → ${options.method} ${options.uri}');
      debugPrint('  headers: ${options.headers}');
      if (options.queryParameters.isNotEmpty) {
        debugPrint('  query: ${options.queryParameters}');
      }
      if (options.data != null) {
        debugPrint('  body: ${_stringify(options.data)}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (_log) {
      final options = response.requestOptions;
      debugPrint('API ← ${response.statusCode} ${options.uri}');
      debugPrint('  headers: ${response.headers.map}');
      debugPrint('  body: ${_responseBody(response.data)}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_log) {
      debugPrint(
        'API ✕ ${err.type.name} '
        '${err.response?.statusCode ?? '-'} '
        '${err.requestOptions.uri}',
      );
      debugPrint('  message: ${err.message}');
      if (err.response?.data != null) {
        debugPrint('  body: ${_responseBody(err.response!.data)}');
      }
    }
    handler.next(err);
  }

  static String _responseBody(Object? data) {
    if (data == null) return '<empty>';
    if (data is ResponseBody) return '<stream>';
    return _stringify(data);
  }

  static String _stringify(Object? data) {
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }
}
