import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';
import '../streaming/gemini_response.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.detail,
    this.statusCode,
    this.type,
    this.isCancel = false,
  });

  static const offlineReason = 'offline';

  final String message;
  final String? detail;
  final int? statusCode;
  final DioExceptionType? type;
  final bool isCancel;

  factory ApiException.fromDio(DioException error) {
    if (isLostConnection(error)) {
      return const ApiException(message: AppConstants.checkYourInternet);
    }
    if (error.type == DioExceptionType.cancel) {
      return switch (error.error) {
        ApiException.offlineReason => const ApiException(
            message: AppConstants.connectionFailed,
            detail: AppConstants.noInternetConnection,
          ),
        _ => const ApiException(
            message: AppConstants.stoppedLabel,
            isCancel: true,
            type: DioExceptionType.cancel,
          ),
      };
    }

    final status = error.response?.statusCode;
    final body = _GeminiBody.read(error.response?.data);
    final policy = body.isContentPolicy;
    final message = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        AppConstants.requestTimedOut,
      DioExceptionType.connectionError => AppConstants.connectionFailed,
      DioExceptionType.badResponse =>
        policy ? AppConstants.contentPolicyBlocked : _titleForStatus(status),
      _ => policy
          ? AppConstants.contentPolicyBlocked
          : AppConstants.geminiRequestFailed,
    };

    return ApiException(
      message: message,
      detail: error.type == DioExceptionType.connectionError
          ? AppConstants.noInternetConnection
          : body.detail(status),
      statusCode: status,
      type: error.type,
    );
  }

  factory ApiException.fromObject(Object error) {
    if (error is ApiException) return error;
    if (isLostConnection(error)) {
      return const ApiException(message: AppConstants.checkYourInternet);
    }
    if (error is DioException) return ApiException.fromDio(error);
    if (error is StateError) {
      return ApiException(
        message: AppConstants.genericError,
        detail: _shorten(error.message, 240),
      );
    }
    return ApiException(
      message: AppConstants.genericError,
      detail: _shorten(error.toString().split('\n').first, 240),
    );
  }

  factory ApiException.contentPolicy({String? reason}) {
    final clean = reason?.trim();
    return ApiException(
      message: AppConstants.contentPolicyBlocked,
      detail: clean == null || clean.isEmpty ? null : 'Blocked: $clean',
    );
  }

  static bool isLostConnection(Object error) {
    if (error is SocketException) return true;
    if (error is HttpException) return _looksOffline(error.message);
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError) return true;
      final cause = error.error;
      if (cause != null && cause != error && isLostConnection(cause)) {
        return true;
      }
      return _looksOffline(error.message ?? '') || _looksOffline('$cause');
    }
    return _looksOffline(error.toString());
  }

  static bool _looksOffline(String text) {
    final value = text.toLowerCase();
    return value.contains('connection closed') ||
        value.contains('connection reset') ||
        value.contains('connection abort') ||
        value.contains('failed host lookup') ||
        value.contains('network is unreachable') ||
        value.contains('software caused connection abort') ||
        value.contains('socketexception');
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

  static String _shorten(String text, int max) {
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.length <= max) return cleaned;
    return '${cleaned.substring(0, max).trimRight()}…';
  }

  @override
  String toString() =>
      'ApiException($message, statusCode: $statusCode, type: $type)';
}

class _GeminiBody {
  const _GeminiBody({this.message, this.status, this.map});

  final String? message;
  final String? status;
  final Map<String, dynamic>? map;

  bool get isContentPolicy {
    final json = map;
    if (json != null) {
      if (GeminiResponse.parse(json).policyReason != null) return true;
      if (_detailReasonBlocked(json)) return true;
    }
    if (status != null && GeminiResponse.isBlockedFinish(status!)) {
      return true;
    }
    return _messageBlocked(message);
  }

  String? detail(int? httpStatus) {
    final clean = _clean(message);
    if (httpStatus == 503) {
      if (clean != null) return clean;
      return AppConstants.serviceUnavailableDetail;
    }
    final parts = <String>[];
    if (httpStatus != null) parts.add('HTTP $httpStatus');
    if (status != null && status!.isNotEmpty) parts.add(status!);
    if (clean != null) parts.add(clean);
    if (parts.isEmpty) return null;
    return parts.join('\n');
  }

  static _GeminiBody read(Object? data) {
    final map = _asMap(data);
    if (map == null) {
      final text = data is String ? data.trim() : '';
      return _GeminiBody(message: text.isEmpty ? null : text);
    }
    final error = map['error'];
    String? message;
    String? status;
    if (error is Map) {
      message = _string(error['message']);
      status = _string(error['status']);
    }
    message ??= _string(map['message']);
    return _GeminiBody(message: message, status: status, map: map);
  }

  static bool _detailReasonBlocked(Map<String, dynamic> json) {
    final error = json['error'];
    if (error is! Map) return false;
    final details = error['details'];
    if (details is! List) return false;
    for (final item in details) {
      if (item is! Map) continue;
      final reason = _string(item['reason']);
      if (reason != null && GeminiResponse.isBlockedFinish(reason)) {
        return true;
      }
    }
    return false;
  }

  static bool _messageBlocked(String? raw) {
    if (raw == null || raw.isEmpty) return false;
    final text = raw.toLowerCase();
    return text.contains('safety') ||
        text.contains('prohibited') ||
        text.contains('content policy') ||
        text.contains('recitation');
  }

  static String? _clean(String? raw) {
    if (raw == null) return null;
    final text = raw.trim();
    if (text.isEmpty) return null;
    final lower = text.toLowerCase();
    if (lower.startsWith('<') || lower.contains('<!doctype')) return null;
    if (text.contains('This exception was thrown because')) return null;
    return ApiException._shorten(text, 280);
  }

  static String? _string(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  static Map<String, dynamic>? _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is! String || data.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } on FormatException {
      return null;
    }
    return null;
  }
}
