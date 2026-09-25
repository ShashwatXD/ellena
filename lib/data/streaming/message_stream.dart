import 'dart:async';

import 'stream_event.dart';

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
