import 'stream_event.dart';

abstract interface class StreamingService {
  int beginGeneration();

  Stream<StreamEvent> streamReply({
    required String prompt,
    required String model,
    List<({String role, String text})> history = const [],
    String? systemInstruction,
  });

  Future<void> cancel();
}
