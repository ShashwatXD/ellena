import 'streaming_service.dart';

class FakeStreamingService implements StreamingService {
  int _epoch = 0;

  @override
  Stream<String> streamReply({
    required String prompt,
    required String model,
    List<({String role, String text})> history = const [],
  }) async* {
    final epoch = ++_epoch;

    const chunks = [
      '## Quick answer\n\n',
      'Here is a **markdown** demo while we wait on a live Gemini key.\n\n',
      '- Model selector is wired through the same stream path\n',
      '- Streaming works the same for fake and Gemini\n',
      '- Stop keeps only what already arrived\n\n',
      '```dart\n',
      'streamingService.streamReply(prompt: prompt, model: model);\n',
      '```\n\n',
      '| Mode | Source |\n',
      '| --- | --- |\n',
      '| Fake | Local scripted chunks |\n',
      '| Gemini | `streamGenerateContent` SSE |\n\n',
      'Ask anything else when you are ready.',
    ];

    for (final chunk in chunks) {
      if (epoch != _epoch) return;
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (epoch != _epoch) return;
      yield chunk;
    }
  }

  @override
  Future<void> cancel() async {
    _epoch++;
  }
}
