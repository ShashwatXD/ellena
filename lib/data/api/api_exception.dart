import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.detail,
    this.statusCode,
    this.type,
    this.isCancel = false,
  });

  final String message;

  final String? detail;

  final int? statusCode;
  final DioExceptionType? type;
  final bool isCancel;

  factory ApiException.fromDio(DioException error) {
    final status = error.response?.statusCode;
    final isCancel = error.type == DioExceptionType.cancel;
    final apiMessage = _readApiMessage(error.response?.data);

    if (isCancel) {
      return const ApiException(
        message: AppConstants.stoppedLabel,
        isCancel: true,
        type: DioExceptionType.cancel,
      );
    }

    final message = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        AppConstants.requestTimedOut,
      DioExceptionType.connectionError => AppConstants.connectionFailed,
      DioExceptionType.badResponse => _titleForStatus(status),
      _ => apiMessage?.isNotEmpty == true
          ? _shorten(apiMessage!, 72)
          : AppConstants.geminiRequestFailed,
    };

    return ApiException(
      message: message,
      detail: _detailFor(status: status, apiMessage: apiMessage),
      statusCode: status,
      type: error.type,
    );
  }

  /// Maps any thrown object into a UI-safe exception (no stack dumps).
  factory ApiException.fromObject(Object error) {
    if (error is ApiException) return error;
    if (error is DioException) return ApiException.fromDio(error);
    if (error is StateError) {
      return ApiException(
        message: AppConstants.mockStreamFailed,
        detail: _shorten(error.message, 240),
      );
    }
    return ApiException(
      message: AppConstants.genericError,
      detail: _shorten(error.toString().split('\n').first, 240),
    );
  }

  static String _titleForStatus(int? status) {
    return switch (status) {
      429 => AppConstants.rateLimitReached,
      401 || 403 => AppConstants.authenticationFailed,
      400 => AppConstants.invalidRequest,
      404 => AppConstants.modelNotFound,
      503 => AppConstants.serviceUnavailable,
      500 || 502 || 504 => AppConstants.serverError,
      _ => status != null
          ? '${AppConstants.geminiRequestFailed} ($status)'
          : AppConstants.geminiRequestFailed,
    };
  }

  static String? _detailFor({
    required int? status,
    required String? apiMessage,
  }) {
    final parts = <String>[];
    if (status != null) parts.add('HTTP $status');
    final clean = _cleanApiMessage(apiMessage);
    if (clean != null) parts.add(clean);
    if (parts.isEmpty) return null;
    return parts.join('\n');
  }

  /// Prefer Gemini's short `error.message`; drop HTML / huge Dio dumps.
  static String? _cleanApiMessage(String? raw) {
    if (raw == null) return null;
    var text = raw.trim();
    if (text.isEmpty) return null;
    if (text.startsWith('<') || text.toLowerCase().contains('<!doctype')) {
      return null;
    }
    // Dio often embeds "This exception was thrown because..." — ignore that.
    if (text.contains('This exception was thrown because')) {
      return null;
    }
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    return _shorten(text, 280);
  }

  static String _shorten(String text, int max) {
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.length <= max) return cleaned;
    return '${cleaned.substring(0, max).trimRight()}…';
  }

  static String? _readApiMessage(Object? data) {
    final map = _asMap(data);
    if (map == null) {
      if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }
      return null;
    }
    final error = map['error'];
    if (error is Map) {
      final message = error['message'];
      if (message is String && message.trim().isNotEmpty) return message.trim();
    }
    final message = map['message'];
    if (message is String && message.trim().isNotEmpty) return message.trim();
    return null;
  }

  static Map<String, dynamic>? _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  @override
  String toString() =>
      'ApiException($message, statusCode: $statusCode, type: $type)';
}
