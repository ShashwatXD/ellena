import 'package:dio/dio.dart';
import 'package:ellena/core/constants/app_constants.dart';
import 'package:ellena/data/network/api_exception.dart';
import 'package:ellena/data/streaming/gemini_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiException content policy', () {
    test('maps Gemini SAFETY HTTP body to content-policy label', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 400,
          data: {
            'error': {
              'code': 400,
              'message': 'The request was blocked by safety filters.',
              'status': 'INVALID_ARGUMENT',
            },
          },
        ),
      );

      final mapped = ApiException.fromDio(error);
      expect(mapped.message, AppConstants.contentPolicyBlocked);
      expect(mapped.detail, AppConstants.contentPolicyDetail);
    });

    test('maps PROHIBITED_CONTENT status to content-policy label', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 400,
          data: {
            'error': {
              'message': 'Request rejected',
              'status': 'PROHIBITED_CONTENT',
            },
          },
        ),
      );

      final mapped = ApiException.fromDio(error);
      expect(mapped.message, AppConstants.contentPolicyBlocked);
    });

    test('uses a short line when a 503 has no readable body', () {
      final empty = ApiException.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 503,
          ),
        ),
      );
      expect(empty.message, AppConstants.serviceUnavailable);
      expect(empty.detail, AppConstants.serviceUnavailableDetail);

      final page = ApiException.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 503,
            data: '<html><body>unavailable</body></html>',
          ),
        ),
      );
      expect(page.detail, AppConstants.serviceUnavailableDetail);

      final explained = ApiException.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 503,
            data: {
              'error': {
                'message': 'The model is overloaded. Please try again later.',
                'status': 'UNAVAILABLE',
              },
            },
          ),
        ),
      );
      expect(
        explained.detail,
        'The model is overloaded. Please try again later.',
      );
    });

    test('maps timeouts and rate limits to their own labels', () {
      final timeout = ApiException.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.receiveTimeout,
        ),
      );
      expect(timeout.message, AppConstants.requestTimedOut);

      final limited = ApiException.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 429,
          ),
        ),
      );
      expect(limited.message, AppConstants.rateLimitReached);
      expect(limited.detail, AppConstants.rateLimitDetail);
    });

    test('keeps invalid request when 400 is not policy-related', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 400,
          data: {
            'error': {
              'message': 'Invalid JSON payload',
              'status': 'INVALID_ARGUMENT',
            },
          },
        ),
      );

      final mapped = ApiException.fromDio(error);
      expect(mapped.message, AppConstants.invalidRequest);
    });
  });

  group('GeminiResponse', () {
    test('reads promptFeedback.blockReason', () {
      expect(
        GeminiResponse.parse({
          'promptFeedback': {'blockReason': 'SAFETY'},
        }).policyReason,
        'SAFETY',
      );
    });

    test('reads candidate finishReason SAFETY', () {
      expect(
        GeminiResponse.parse({
          'candidates': [
            {'finishReason': 'SAFETY'},
          ],
        }).policyReason,
        'SAFETY',
      );
    });

    test('ignores normal STOP finish', () {
      final parsed = GeminiResponse.parse({
        'candidates': [
          {
            'finishReason': 'STOP',
            'content': {
              'parts': [
                {'text': 'hi'},
              ],
            },
          },
        ],
      });
      expect(parsed.policyReason, isNull);
      expect(parsed.text, 'hi');
      expect(parsed.finishReason, 'STOP');
    });
  });
}
