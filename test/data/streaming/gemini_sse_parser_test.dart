import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:ellena/data/streaming/gemini_response.dart';
import 'package:ellena/data/streaming/gemini_sse_parser.dart';

void main() {
  group('GeminiSseParser', () {
    test('parses CRLF SSE the way Gemini serves alt=sse', () async {
      final bytes = Uint8List.fromList(
        utf8.encode(
          'data: {"candidates":[{"content":{"parts":[{"text":"New"}]}}]}\r\n'
          '\r\n'
          'data: {"candidates":[{"content":{"parts":[{"text":" Delhi"}]}}]}\r\n'
          '\r\n',
        ),
      );

      final events =
          await GeminiSseParser.parse(Stream.value(bytes)).toList();

      expect(events, hasLength(2));
      expect(
        GeminiResponse.parse(events[0]).text,
        'New',
      );
      expect(
        GeminiResponse.parse(events[1]).text,
        ' Delhi',
      );
    });

    test('parses LF-only SSE (Dart SDK unit-test style)', () async {
      final bytes = Uint8List.fromList(
        utf8.encode(
          'data: {"candidates":[{"content":{"parts":[{"text":"Hi"}]}}]}\n'
          'data: {"candidates":[{"content":{"parts":[{"text":"!"}]}}]}\n',
        ),
      );

      final events =
          await GeminiSseParser.parse(Stream.value(bytes)).toList();
      expect(events, hasLength(2));
      expect(GeminiResponse.parse(events[0]).text, 'Hi');
      expect(GeminiResponse.parse(events[1]).text, '!');
    });

    test('ignores non-data SSE lines', () async {
      final bytes = Uint8List.fromList(
        utf8.encode(
          ': keep-alive\r\n'
          'data: {"candidates":[{"content":{"parts":[{"text":"ok"}]}}]}\r\n'
          '\r\n',
        ),
      );

      final events =
          await GeminiSseParser.parse(Stream.value(bytes)).toList();
      expect(events, hasLength(1));
      expect(GeminiResponse.parse(events.single).text, 'ok');
    });
  });

  group('GeminiResponse', () {
    test('skips thought parts per thinking docs', () {
      final parsed = GeminiResponse.parse({
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'reasoning…', 'thought': true},
                {'text': 'New Delhi'},
              ],
            },
          },
        ],
      });
      expect(parsed.text, 'New Delhi');
    });
  });
}
