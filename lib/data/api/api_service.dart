import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/result/result.dart';
import 'api_exception.dart';

class ApiService {
  ApiService({
    required String baseUrl,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: const {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  final Dio _dio;

  Future<Result<Response<T>>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Result<Response<T>>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Result<Response<T>>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(
      () => _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Result<Response<T>>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(
      () => _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Result<Response<T>>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(
      () => _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Result<Response<T>>> _guard<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      return Success(await request());
    } on DioException catch (error, stackTrace) {
      final exception = ApiException.fromDio(error);
      debugPrint(
        'API ✕ ${error.requestOptions.method} '
        '${_redactUri(error.requestOptions.uri)} → $exception',
      );
      return Failure(exception, stackTrace);
    } catch (error, stackTrace) {
      debugPrint('API ✕ $error');
      return Failure(error, stackTrace);
    }
  }

  static String _redactUri(Uri uri) {
    if (!uri.queryParameters.containsKey('key')) return uri.toString();
    final params = Map<String, String>.from(uri.queryParameters)
      ..['key'] = '***';
    return uri.replace(queryParameters: params).toString();
  }
}
