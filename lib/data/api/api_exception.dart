import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.type,
    this.isCancel = false,
  });

  final String message;
  final int? statusCode;
  final DioExceptionType? type;
  final bool isCancel;

  factory ApiException.fromDio(DioException error) {
    final status = error.response?.statusCode;
    final isCancel = error.type == DioExceptionType.cancel;

    final message = switch (error.type) {
      DioExceptionType.cancel => 'Request cancelled',
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Request timed out',
      DioExceptionType.connectionError => 'Connection failed',
      DioExceptionType.badResponse =>
        'Request failed${status != null ? ' ($status)' : ''}',
      _ => error.message?.isNotEmpty == true
          ? error.message!
          : 'Request failed',
    };

    return ApiException(
      message: message,
      statusCode: status,
      type: error.type,
      isCancel: isCancel,
    );
  }

  @override
  String toString() =>
      'ApiException($message, statusCode: $statusCode, type: $type)';
}
