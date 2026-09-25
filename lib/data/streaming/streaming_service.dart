import 'stream_event.dart';

abstract interface class StreamingService {
  /// Bumps the stream generation. In-flight events keep the old id and must drop.
  int beginGeneration();

  Stream<StreamEvent> streamReply({
    required String prompt,
    required String model,
    List<({String role, String text})> history = const [],
  });

  Future<void> cancel();
}
