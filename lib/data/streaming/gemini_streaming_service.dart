import 'dart:async';

import 'package:dio/dio.dart';

import '../api/api_exception.dart';
import '../api/api_repository.dart';
import 'gemini_response_text.dart';
import 'gemini_sse_parser.dart';
import 'streaming_service.dart';

class GeminiStreamingService implements StreamingService {
  GeminiStreamingService({
    required ApiRepository repository,
    required this.apiKey,
  }) : _repository = repository;

  final ApiRepository _repository;
  final String apiKey;

  CancelToken? _cancelToken;

  @override
  Stream<String> streamReply({
    required String prompt,
    required String model,
    List<({String role, String text})> history = const [],
  }) async* {
    await cancel();
    _cancelToken = CancelToken();
    final token = _cancelToken!;

    // Multi-turn shape from Gemini docs: alternating user / model contents,
    // then the latest user turn.
    // https://ai.google.dev/api/generate-content
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

    final result = await _repository.streamGeminiGenerateContent(
      model: model,
      apiKey: apiKey,
      body: {'contents': contents},
      cancelToken: token,
    );

    final response = result.when(
      success: (value) => value,
      failure: (error, stackTrace) {
        if (error is ApiException) {
          throw error;
        }
        Error.throwWithStackTrace(error, stackTrace ?? StackTrace.current);
      },
    );

    final body = response.data;
    if (body == null) return;

    await for (final json in GeminiSseParser.parse(body.stream)) {
      if (token.isCancelled) return;
      final text = GeminiResponseText.fromResponse(json);
      if (text != null) yield text;
    }
  }

  @override
  Future<void> cancel() async {
    final token = _cancelToken;
    _cancelToken = null;
    if (token != null && !token.isCancelled) {
      token.cancel('stopped');
    }
  }
}
