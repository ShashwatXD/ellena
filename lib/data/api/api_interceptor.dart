import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/result/result.dart';
import 'api_exception.dart';
import '../../core/config/app_config.dart';

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
    if (AppConfig.isDev && err.type != DioExceptionType.cancel) {
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

bool hasNetwork(List<ConnectivityResult> results) {
  return results.any((result) => result != ConnectivityResult.none);
}

Future<Result<bool>> readNetwork(Connectivity link) {
  return link.checkConnectivity().then(
    (results) => Success(hasNetwork(results)),
    onError: (Object error, StackTrace stackTrace) =>
        Failure<bool>(error, stackTrace),
  );
}

StreamSubscription<List<ConnectivityResult>> watchNetwork(
  void Function(Result<bool> status) onStatus,
) {
  final link = Connectivity();
  unawaited(readNetwork(link).then(onStatus));
  return link.onConnectivityChanged.listen(
    (results) => onStatus(Success(hasNetwork(results))),
    onError: (Object error, StackTrace stackTrace) {
      onStatus(Failure<bool>(error, stackTrace));
    },
  );
}

class NetworkInterceptor extends Interceptor {
  NetworkInterceptor({bool watch = true}) {
    if (watch) _subscription = watchNetwork(_apply);
  }

  void _apply(Result<bool> status) {
    status.when(
      success: setOnline,
      failure: (error, stackTrace) => setOnline(false),
    );
  }

  bool _online = true;
  final List<CancelToken> _live = [];
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void setOnline(bool online) {
    _online = online;
    if (!online) {
      for (final token in List<CancelToken>.of(_live)) {
        if (!token.isCancelled) token.cancel(ApiException.offlineReason);
      }
    }
  }

  void close() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_online) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      );
      return;
    }
    final token = options.cancelToken;
    if (token != null) _live.add(token);
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final token = response.requestOptions.cancelToken;
    final data = response.data;
    if (token != null && data is ResponseBody) {
      data.stream = _releaseWhenDone(data.stream, token);
    } else {
      _live.remove(token);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _live.remove(err.requestOptions.cancelToken);
    handler.next(err);
  }

  Stream<Uint8List> _releaseWhenDone(
    Stream<Uint8List> source,
    CancelToken token,
  ) async* {
    try {
      await for (final chunk in source) {
        yield chunk;
      }
    } finally {
      _live.remove(token);
    }
  }
}
