import '../../core/models/chat_attachment.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/mock_stream_scenario.dart';
import '../network/api_exception.dart';
import 'stream_event.dart';
import 'streaming_service.dart';

class FakeStreamingService implements StreamingService {
  FakeStreamingService({required this.scenarioOf});

  final MockStreamScenario Function() scenarioOf;
  int _generation = 0;

  @override
  int beginGeneration() => ++_generation;

  @override
  Stream<StreamEvent> streamReply({
    required String prompt,
    required String model,
    List<ChatTurn> history = const [],
    String? systemInstruction,
    ChatAttachment? attachment,
  }) async* {
    final generation = _generation;
    final scenario = scenarioOf();
    final chunks = scenario.chunks;
    final delay = scenario.chunkDelay;
    final failAfter = scenario.failAfterYields;
    final failure = _failureFor(scenario.failure);
    var seqCursor = StreamCursor(generation);
    var yielded = 0;

    bool alive() => generation == _generation;

    while (alive()) {
      if (failAfter != null && yielded >= failAfter) {
        await Future<void>.delayed(delay);
        if (!alive()) return;
        throw failure!;
      }
      if (yielded >= chunks.length) {
        yield seqCursor.meta(StreamEvent.finishReasonKey, 'STOP');
        return;
      }
      await Future<void>.delayed(delay);
      if (!alive()) return;
      yield seqCursor.text(chunks[yielded++]);
    }
  }

  @override
  Future<void> cancel() async {
    _generation++;
  }
}

Object? _failureFor(MockStreamFailure failure) {
  return switch (failure) {
    MockStreamFailure.none => null,
    MockStreamFailure.unavailable => const ApiException(
      message: AppConstants.serviceUnavailable,
      detail: AppConstants.serviceUnavailableDetail,
      statusCode: 503,
    ),
    MockStreamFailure.timedOut => const ApiException(
      message: AppConstants.requestTimedOut,
    ),
    MockStreamFailure.offline => const ApiException(
      message: AppConstants.connectionFailed,
      detail: AppConstants.noInternetConnection,
    ),
    MockStreamFailure.blocked => ApiException.contentPolicy(reason: 'SAFETY'),
    MockStreamFailure.rateLimited => const ApiException(
      message: AppConstants.rateLimitReached,
      detail: AppConstants.rateLimitDetail,
      statusCode: 429,
    ),
  };
}
