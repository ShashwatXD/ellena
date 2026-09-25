class GeminiResponse {
  const GeminiResponse({
    this.text,
    this.blockReason,
    this.finishReason,
  });

  final String? text;
  final String? blockReason;
  final String? finishReason;

  static const blockedFinishes = {
    'SAFETY',
    'RECITATION',
    'PROHIBITED_CONTENT',
    'BLOCKLIST',
    'SPII',
    'IMAGE_SAFETY',
  };

  static bool isBlockedFinish(String finish) =>
      blockedFinishes.contains(finish);

  String? get policyReason {
    final block = blockReason;
    if (block != null && block.isNotEmpty) return block;
    final finish = finishReason;
    if (finish != null && isBlockedFinish(finish)) return finish;
    return null;
  }

  factory GeminiResponse.parse(Map<String, dynamic> json) {
    String? blockReason;
    final feedback = json['promptFeedback'];
    if (feedback is Map) {
      blockReason = _text(feedback['blockReason']);
    }

    String? finishReason;
    String? text;
    final candidates = json['candidates'];
    if (candidates is List && candidates.isNotEmpty) {
      final candidate = candidates.first;
      if (candidate is Map) {
        finishReason = _text(candidate['finishReason']);
        text = _candidateText(candidate['content']);
      }
    }

    return GeminiResponse(
      text: text,
      blockReason: blockReason,
      finishReason: finishReason,
    );
  }

  static String? _candidateText(Object? content) {
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

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
