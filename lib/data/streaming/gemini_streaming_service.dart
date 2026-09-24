import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../api/api_repository.dart';
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

    final response = await _repository.streamGeminiGenerateContent(
      model: model,
      apiKey: apiKey,
      body: {'contents': contents},
      cancelToken: _cancelToken,
    );

    final body = response.data;
    if (body == null) return;

    yield* _parseSse(body.stream);
  }

  Stream<String> _parseSse(Stream<Uint8List> byteStream) async* {
    final buffer = StringBuffer();

    await for (final chunk in byteStream.transform(
      StreamTransformer<Uint8List, String>.fromHandlers(
        handleData: (data, sink) {
          sink.add(utf8.decode(data, allowMalformed: true));
        },
      ),
    )) {
      if (_cancelToken?.isCancelled ?? true) return;
      buffer.write(chunk);

      while (true) {
        final raw = buffer.toString();
        final separator = raw.indexOf('\n\n');
        if (separator < 0) break;

        final event = raw.substring(0, separator);
        buffer
          ..clear()
          ..write(raw.substring(separator + 2));

        for (final line in event.split('\n')) {
          final trimmed = line.trimRight();
          if (!trimmed.startsWith('data:')) continue;

          final payload = trimmed.substring(5).trim();
          if (payload.isEmpty || payload == '[DONE]') continue;

          final text = _extractText(payload);
          if (text != null && text.isNotEmpty) yield text;
        }
      }
    }

    if (_cancelToken?.isCancelled ?? true) return;

    final trailing = buffer.toString().trim();
    if (trailing.startsWith('data:')) {
      final payload = trailing.substring(5).trim();
      final text = _extractText(payload);
      if (text != null && text.isNotEmpty) yield text;
    }
  }

  String? _extractText(String payload) {
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      final candidates = json['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) return null;

      final content = candidates.first as Map<String, dynamic>;
      final parts =
          (content['content'] as Map<String, dynamic>?)?['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) return null;

      final texts = <String>[];
      for (final part in parts) {
        if (part is Map<String, dynamic> && part['text'] is String) {
          texts.add(part['text'] as String);
        }
      }
      if (texts.isEmpty) return null;
      return texts.join();
    } on FormatException {
      return null;
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
