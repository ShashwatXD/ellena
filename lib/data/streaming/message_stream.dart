import 'dart:async';

import 'stream_event.dart';

/// One in-flight reply: generation gate plus its subscription.
class MessageStream {
  MessageStream(this.generation) : gate = StreamEventGate(generation);

  final int generation;
  final StreamEventGate gate;
  StreamSubscription<StreamEvent>? subscription;

  bool accept(StreamEvent event) => gate.accept(event);

  Future<void> cancel() async {
    final current = subscription;
    subscription = null;
    await current?.cancel();
  }
}
