import '../../core/constants/app_constants.dart';
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

    for (final chunk in AppConstants.fakeStreamChunks) {
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
