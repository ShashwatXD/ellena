import '../../core/constants/app_constants.dart';
import '../../core/models/llm_model.dart';
import '../api/api_repository.dart';
import 'gemini_response.dart';

class GeminiTitleService {
  GeminiTitleService({
    required ApiRepository repository,
    required this.apiKey,
  }) : _repository = repository;

  final ApiRepository _repository;
  final String apiKey;

  static const int _snippetChars = 120;
  static const int _maxTitleChars = 48;
  static const _quoteChars = {
    '"',
    "'",
    '\u201C',
    '\u201D',
    '\u2018',
    '\u2019',
  };

  Future<String?> generateTitle(String firstUserMessage) async {
    if (apiKey.isEmpty) return null;

    final snippet = _snippet(firstUserMessage);
    if (snippet.isEmpty) return null;

    final result = await _repository.generateGeminiContent(
      model: GeminiModels.flashLite.id,
      body: {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {
                'text': '${AppConstants.titlePromptPrefix}$snippet',
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.2,
          'maxOutputTokens': 24,
        },
      },
    );

    return result.when(
      success: (response) => _parseTitle(response.data),
      failure: (error, stackTrace) => null,
    );
  }

  String _snippet(String text) {
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.length <= _snippetChars) return cleaned;
    return cleaned.substring(0, _snippetChars);
  }

  String? _parseTitle(Map<String, dynamic>? data) {
    if (data == null) return null;
    final raw = GeminiResponse.parse(data).text;
    if (raw == null) return null;

    var title = _stripEdgeQuotes(
      raw
          .trim()
          .replaceAll(RegExp(r'[\r\n]+'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim(),
    );

    if (title.isEmpty) return null;
    if (title.length > _maxTitleChars) {
      title = title.substring(0, _maxTitleChars).trim();
    }
    return title;
  }

  String _stripEdgeQuotes(String value) {
    var title = value;
    while (title.isNotEmpty && _quoteChars.contains(title[0])) {
      title = title.substring(1).trimLeft();
    }
    while (title.isNotEmpty &&
        _quoteChars.contains(title[title.length - 1])) {
      title = title.substring(0, title.length - 1).trimRight();
    }
    return title;
  }
}
