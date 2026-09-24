abstract final class GeminiResponseText {
  static String? fromResponse(Map<String, dynamic> json) {
    final candidates = json['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;

    final candidate = candidates.first;
    if (candidate is! Map) return null;

    final content = candidate['content'];
    if (content is! Map) return null;

    final parts = content['parts'];
    if (parts is! List || parts.isEmpty) return null;

    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is! Map) continue;
      if (part['thought'] == true) continue;
      final text = part['text'];
      if (text is String && text.isNotEmpty) buffer.write(text);
    }

    final value = buffer.toString();
    return value.isEmpty ? null : value;
  }
}
