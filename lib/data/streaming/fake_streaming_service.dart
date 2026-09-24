import '../../core/constants/app_constants.dart';
import '../../core/models/mock_stream_scenario.dart';
import 'streaming_service.dart';

class FakeStreamingService implements StreamingService {
  FakeStreamingService({required this.scenarioOf});

  final MockStreamScenario Function() scenarioOf;
  int _epoch = 0;

  @override
  Stream<String> streamReply({
    required String prompt,
    required String model,
    List<({String role, String text})> history = const [],
  }) async* {
    final epoch = ++_epoch;
    final scenario = scenarioOf();
    final chunks = scenario.chunks;
    final delay = scenario.chunkDelay;
    final failAfter = scenario.failAfterYields;

    var yielded = 0;
    while (true) {
      if (epoch != _epoch) return;
      if (failAfter != null && yielded >= failAfter) {
        await Future<void>.delayed(delay);
        if (epoch != _epoch) return;
        throw StateError(AppConstants.mockStreamFailed);
      }
      if (yielded >= chunks.length) return;
      await Future<void>.delayed(delay);
      if (epoch != _epoch) return;
      yield chunks[yielded++];
    }
  }

  @override
  Future<void> cancel() async {
    _epoch++;
  }
}
