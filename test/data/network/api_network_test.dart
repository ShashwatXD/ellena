import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ellena/core/constants/app_constants.dart';
import 'package:ellena/core/result/result.dart';
import 'package:ellena/data/network/api_exception.dart';
import 'package:ellena/data/network/api_service.dart';
import 'package:ellena/data/network/api_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('offline before the call returns Failure and does not hit the network', () async {
    final client = _client(_Hang());
    client.network.setOnline(false);

    final result = await client.api.post<String>('/ping', cancelToken: CancelToken());

    expect(result, isA<Failure<Response<String>>>());
    final error = (result as Failure<Response<String>>).error;
    expect(error, isA<ApiException>());
    expect((error as ApiException).message, AppConstants.connectionFailed);
  });

  test('network lost cancels the live call as a connection failure', () async {
    final client = _client(_Hang());
    final pending = client.api.post<String>('/stream', cancelToken: CancelToken());

    client.network.setOnline(false);
    final result = await pending;

    expect(result, isA<Failure<Response<String>>>());
    final error = (result as Failure<Response<String>>).error as ApiException;
    expect(error.message, AppConstants.connectionFailed);
    expect(error.isCancel, isFalse);
  });

  test('a live call stays open until stop or offline', () async {
    final client = _client(_Hang());
    final token = CancelToken();
    final pending = client.api.post<String>('/stream', cancelToken: token);

    await Future<void>.delayed(Duration.zero);
    expect(token.isCancelled, isFalse);

    token.cancel('stopped');
    final result = await pending;
    final error = (result as Failure<Response<String>>).error as ApiException;
    expect(error.isCancel, isTrue);
    expect(error.message, AppConstants.stoppedLabel);
  });

  test('network lost during a stream cancels the open body', () async {
    final adapter = _OpenBody();
    final client = _client(adapter);
    final token = CancelToken();
    final result = await client.api.post<ResponseBody>(
      '/sse',
      cancelToken: token,
      options: Options(responseType: ResponseType.stream),
    );

    final body = (result as Success<Response<ResponseBody>>).value.data!;
    final chunks = <Uint8List>[];
    final errors = <Object>[];
    final done = body.stream.listen(chunks.add, onError: errors.add);

    client.network.setOnline(false);
    await pumpEventQueue();

    expect(token.isCancelled, isTrue);
    expect(errors, isNotEmpty);
    await done.cancel();
  });

  test('user stop stays a cancel, not an interruption', () {
    final mapped = ApiException.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.cancel,
        error: 'stopped',
      ),
    );
    expect(mapped.isCancel, isTrue);
    expect(mapped.message, AppConstants.stoppedLabel);
  });
}

ApiClient _client(HttpClientAdapter adapter) {
  final dio = Dio();
  dio.httpClientAdapter = adapter;
  final network = NetworkInterceptor(watch: false);
  final api = ApiService(
    baseUrl: 'https://example.test',
    apiKey: 'test-key',
    dio: dio,
    network: network,
  );
  return (api: api, network: network);
}

typedef ApiClient = ({ApiService api, NetworkInterceptor network});

class _Hang implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final done = Completer<ResponseBody>();
    cancelFuture?.then((_) {
      if (!done.isCompleted) {
        done.completeError(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: options.cancelToken?.cancelError?.error,
          ),
        );
      }
    });
    return done.future;
  }

  @override
  void close({bool force = false}) {}
}

class _OpenBody implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final controller = StreamController<Uint8List>();
    cancelFuture?.then((_) {
      if (!controller.isClosed) controller.close();
    });
    return ResponseBody(controller.stream, 200);
  }

  @override
  void close({bool force = false}) {}
}
