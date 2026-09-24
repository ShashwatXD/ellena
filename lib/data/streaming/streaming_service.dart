abstract interface class StreamingService {
  Stream<String> streamReply({
    required String prompt,
    required String model,
    List<({String role, String text})> history = const [],
  });

  Future<void> cancel();
}
