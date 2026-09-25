import 'dart:async';

import 'package:dio/dio.dart';

import '../network/api_exception.dart';
import '../network/api_repository.dart';
import 'gemini_response.dart';
import 'gemini_sse_parser.dart';
import 'stream_event.dart';
import 'streaming_service.dart';

class GeminiStreamingService implements StreamingService {
  GeminiStreamingService({required ApiRepository repository})
      : _repository = repository;

  final ApiRepository _repository;

  CancelToken? _cancelToken;
  int _generation = 0;

  @override
  int beginGeneration() => ++_generation;

  @override
  Stream<StreamEvent> streamReply({
    required String prompt,
    required String model,
    List<({String role, String text})> history = const [],
    String? systemInstruction,
  }) {
    final generation = _generation;
    return _events(
      prompt: prompt,
      model: model,
      history: history,
      generation: generation,
      systemInstruction: systemInstruction,
    );
  }

  Stream<StreamEvent> _events({
    required String prompt,
    required String model,
    required List<({String role, String text})> history,
    required int generation,
    String? systemInstruction,
  }) async* {
    if (generation != _generation) return;

    try {
      await _abortHttp();
      if (generation != _generation) return;

      _cancelToken = CancelToken();
      final token = _cancelToken!;
      final cursor = StreamCursor(generation);

      bool alive() => generation == _generation && !token.isCancelled;

      final instruction = systemInstruction?.trim();
      final contents = <Map<String, dynamic>>[
        for (final turn in history)
          {
            'role': turn.role == 'assistant' ? 'model' : 'user',
            'parts': [
              {'text': turn.text},
            ],
          },
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ];

      final requestBody = <String, dynamic>{
        'contents': contents,
        if (instruction != null && instruction.isNotEmpty)
          'systemInstruction': {
            'parts': [
              {'text': instruction},
            ],
          },
      };

      final result = await _repository.streamGeminiGenerateContent(
        model: model,
        body: requestBody,
        cancelToken: token,
      );
      if (!alive()) return;

      final response = result.when(
        success: (value) => value,
        failure: (error, stackTrace) {
          if (_isUserCancel(error) || !alive()) return null;
          if (error is ApiException) throw error;
          Error.throwWithStackTrace(error, stackTrace ?? StackTrace.current);
        },
      );
      final body = response?.data;
      if (body == null) return;

      await for (final json in GeminiSseParser.parse(body.stream)) {
        if (!alive()) return;

        final parsed = GeminiResponse.parse(json);
        final text = parsed.text;
        if (text != null) yield cursor.text(text);

        final finish = parsed.finishReason;
        if (finish != null) {
          yield cursor.meta(StreamEvent.finishReasonKey, finish);
        }
        final policy = parsed.policyReason;
        if (policy != null) {
          yield cursor.meta(StreamEvent.contentPolicyKey, policy);
        }
      }
    } on DioException catch (error) {
      if (_isUserCancel(error) || generation != _generation) return;
      throw ApiException.fromDio(error);
    } on ApiException catch (error) {
      if (error.isCancel || generation != _generation) return;
      rethrow;
    }
  }

  bool _isUserCancel(Object error) {
    if (error is ApiException) return error.isCancel;
    if (error is DioException) return error.type == DioExceptionType.cancel;
    return false;
  }

  Future<void> _abortHttp() async {
    final token = _cancelToken;
    _cancelToken = null;
    if (token != null && !token.isCancelled) {
      token.cancel('stopped');
    }
  }

  @override
  Future<void> cancel() async {
    _generation++;
    await _abortHttp();
  }
}
