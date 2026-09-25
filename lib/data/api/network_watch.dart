import 'dart:async';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'api_exception.dart';

bool hasNetwork(List<ConnectivityResult> results) {
  return results.any((result) => result != ConnectivityResult.none);
}

StreamSubscription<List<ConnectivityResult>> watchNetwork(
  void Function(bool online) onChanged,
) {
  final link = Connectivity();
  void apply(List<ConnectivityResult> results) =>
      onChanged(hasNetwork(results));

  unawaited(() async {
    try {
      apply(await link.checkConnectivity());
    } catch (_) {}
  }());

  return link.onConnectivityChanged.listen(apply);
}

/// Blocks new calls when offline and cancels calls already on the wire.
class NetworkInterceptor extends Interceptor {
  NetworkInterceptor({bool watch = true}) {
    if (watch) _subscription = watchNetwork(setOnline);
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
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
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
