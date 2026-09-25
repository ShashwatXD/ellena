import 'package:dio/dio.dart';

import '../../core/result/result.dart';
import 'api_exception.dart';
import 'api_interceptor.dart';
import 'network_watch.dart';

class ApiService {
  ApiService({
    required String baseUrl,
    required String apiKey,
    Dio? dio,
    NetworkInterceptor? network,
  }) : _network = network ?? NetworkInterceptor(),
       _dio = dio ??
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
            ) {
    _dio.interceptors.addAll([
      ApiKeyInterceptor(apiKey),
      _network,
      ApiErrorInterceptor(),
    ]);
  }

  final Dio _dio;
  final NetworkInterceptor _network;

  void dispose() => _network.close();

  Future<Result<Response<T>>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _send(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Result<Response<T>>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _send(
      method: 'POST',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Result<Response<T>>> _send<T>({
    required String method,
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(
      () => _dio.request<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: (options ?? Options()).copyWith(method: method),
      ),
    );
  }

  Future<Result<Response<T>>> _guard<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      return Success(await request());
    } on DioException catch (error, stackTrace) {
      return Failure(ApiException.fromDio(error), stackTrace);
    } catch (error, stackTrace) {
      return Failure(error, stackTrace);
    }
  }
}
