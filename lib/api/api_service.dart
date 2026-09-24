import 'package:dio/dio.dart';

import 'api_interceptor.dart';

class ApiService {
  ApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: const {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(ApiInterceptor());
  }

  final Dio _dio;

  Dio get client => _dio;
}
