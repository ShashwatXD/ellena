import 'package:ellena/core/constants/app_constants.dart';
import 'package:ellena/core/models/mock_stream_scenario.dart';
import 'package:ellena/data/network/api_exception.dart';
import 'package:ellena/data/streaming/fake_streaming_service.dart';
import 'package:ellena/data/streaming/stream_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FakeStreamingService service(MockStreamScenario scenario) {
    return FakeStreamingService(scenarioOf: () => scenario);
  }

  test('a short reply ends with a STOP meta event', () async {
    final stream = service(MockStreamScenario.short);
    stream.beginGeneration();

    final events = await stream
        .streamReply(prompt: 'hi', model: 'gemini-3.5-flash')
        .toList();

    expect(events.first.text, AppConstants.mockChunksShort.single);
    expect(events.last.metaKey, StreamEvent.finishReasonKey);
    expect(events.last.metaValue, 'STOP');
  });

  test('an early failure is a 503 before any text', () async {
    final stream = service(MockStreamScenario.errorEarly);
    stream.beginGeneration();

    await expectLater(
      stream.streamReply(prompt: 'hi', model: 'm').toList(),
      throwsA(
        isA<ApiException>()
            .having(
              (error) => error.message,
              'message',
              AppConstants.serviceUnavailable,
            )
            .having(
              (error) => error.detail,
              'detail',
              AppConstants.serviceUnavailableDetail,
            ),
      ),
    );
  });

  test('a mid-stream failure is a timeout after some text', () async {
    final stream = service(MockStreamScenario.errorMid);
    stream.beginGeneration();

    Object? thrown;
    final texts = <String>[];
    try {
      await for (final event in stream.streamReply(prompt: 'hi', model: 'm')) {
        final text = event.text;
        if (text != null) texts.add(text);
      }
    } catch (error) {
      thrown = error;
    }

    expect(texts, AppConstants.mockChunksErrorMid.take(3));
    expect(
      thrown,
      isA<ApiException>().having(
        (error) => error.message,
        'message',
        AppConstants.requestTimedOut,
      ),
    );
  });

  test(
    'blocked, rate limit, and a timeout before text match the Gemini lines',
    () async {
      Future<ApiException> thrownFor(MockStreamScenario scenario) async {
        final stream = service(scenario);
        stream.beginGeneration();
        try {
          await stream.streamReply(prompt: 'hi', model: 'm').toList();
        } on ApiException catch (error) {
          return error;
        }
        fail('expected an ApiException');
      }

      final blocked = await thrownFor(MockStreamScenario.blocked);
      expect(blocked.message, AppConstants.contentPolicyBlocked);
      expect(blocked.detail, AppConstants.contentPolicyDetail);

      final limited = await thrownFor(MockStreamScenario.rateLimited);
      expect(limited.message, AppConstants.rateLimitReached);
      expect(limited.detail, AppConstants.rateLimitDetail);

      final timedOut = await thrownFor(MockStreamScenario.timedOut);
      expect(timedOut.message, AppConstants.requestTimedOut);
      expect(timedOut.detail, isNull);
    },
  );

  test('offline scenario throws a connection failure', () async {
    final stream = service(MockStreamScenario.offline);
    stream.beginGeneration();

    await expectLater(
      stream.streamReply(prompt: 'hi', model: 'm').toList(),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          AppConstants.connectionFailed,
        ),
      ),
    );
  });
}
