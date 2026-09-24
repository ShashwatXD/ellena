import 'dart:convert';
import 'dart:typed_data';

/// Parses Gemini `streamGenerateContent?alt=sse` like Google's Dart client:
/// UTF-8 decode → [LineSplitter] → `data: ` JSON lines.
///
/// Dio's body stream is [Stream]<[Uint8List]>. [utf8.decoder] is typed as
/// `StreamTransformer<List<int>, String>`, so we cast the stream first.
abstract final class GeminiSseParser {
  static const dataPrefix = 'data: ';

  static Stream<Map<String, dynamic>> parse(Stream<Uint8List> byteStream) {
    return byteStream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .where((line) => line.startsWith(dataPrefix))
        .map((line) {
          final jsonText = line.substring(dataPrefix.length);
          final decoded = jsonDecode(jsonText);
          if (decoded is! Map) {
            throw const FormatException('SSE data was not a JSON object');
          }
          return Map<String, dynamic>.from(decoded);
        });
  }
}
