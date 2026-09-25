import 'package:ellena/data/streaming/stream_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StreamEventGate', () {
    test('accepts text then metadata in sequence', () {
      final gate = StreamEventGate(1);

      expect(
        gate.accept(
          const StreamEvent.text(generation: 1, seq: 1, text: 'Hi'),
        ),
        isTrue,
      );
      expect(
        gate.accept(
          const StreamEvent.meta(
            generation: 1,
            seq: 2,
            key: StreamEvent.finishReasonKey,
            value: 'STOP',
          ),
        ),
        isTrue,
      );
    });

    test('rejects stale metadata from an older generation', () {
      final previous = StreamEventGate(1);
      previous.accept(
        const StreamEvent.text(generation: 1, seq: 1, text: 'old'),
      );

      final current = StreamEventGate(2);
      current.accept(
        const StreamEvent.text(generation: 2, seq: 1, text: 'new'),
      );

      expect(
        current.accept(
          const StreamEvent.meta(
            generation: 1,
            seq: 2,
            key: StreamEvent.contentPolicyKey,
            value: 'SAFETY',
          ),
        ),
        isFalse,
      );
      expect(
        current.accept(
          const StreamEvent.meta(
            generation: 2,
            seq: 2,
            key: StreamEvent.finishReasonKey,
            value: 'STOP',
          ),
        ),
        isTrue,
      );
    });

    test('rejects a replayed or out-of-order seq', () {
      final gate = StreamEventGate(4);
      const first = StreamEvent.text(generation: 4, seq: 1, text: 'a');
      expect(gate.accept(first), isTrue);
      expect(gate.accept(first), isFalse);
      expect(
        gate.accept(
          const StreamEvent.meta(
            generation: 4,
            seq: 1,
            key: StreamEvent.finishReasonKey,
            value: 'STOP',
          ),
        ),
        isFalse,
      );
    });
  });
}
