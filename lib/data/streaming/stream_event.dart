enum StreamChannel { text, meta }

class StreamEvent {
  const StreamEvent._({
    required this.generation,
    required this.seq,
    required this.channel,
    this.text,
    this.metaKey,
    this.metaValue,
  });

  const StreamEvent.text({
    required int generation,
    required int seq,
    required String text,
  }) : this._(
          generation: generation,
          seq: seq,
          channel: StreamChannel.text,
          text: text,
        );

  const StreamEvent.meta({
    required int generation,
    required int seq,
    required String key,
    required String value,
  }) : this._(
          generation: generation,
          seq: seq,
          channel: StreamChannel.meta,
          metaKey: key,
          metaValue: value,
        );

  final int generation;
  final int seq;
  final StreamChannel channel;
  final String? text;
  final String? metaKey;
  final String? metaValue;

  bool get isText => channel == StreamChannel.text;
  bool get isMeta => channel == StreamChannel.meta;

  bool get isContentPolicy => isMeta && metaKey == contentPolicyKey;

  static const contentPolicyKey = 'contentPolicy';
  static const finishReasonKey = 'finishReason';
}

class StreamEventGate {
  StreamEventGate(this.generation);

  final int generation;
  int lastSeq = 0;

  bool accept(StreamEvent event) {
    if (event.generation != generation) return false;
    if (event.seq <= lastSeq) return false;
    lastSeq = event.seq;
    return true;
  }
}

class StreamCursor {
  StreamCursor(this.generation);

  final int generation;
  int _seq = 0;

  StreamEvent text(String text) => StreamEvent.text(
        generation: generation,
        seq: ++_seq,
        text: text,
      );

  StreamEvent meta(String key, String value) => StreamEvent.meta(
        generation: generation,
        seq: ++_seq,
        key: key,
        value: value,
      );
}
