import '../../core/models/chat_attachment.dart';
import 'stream_event.dart';

typedef ChatTurn = ({
  String role,
  String text,
  ChatAttachment? attachment,
});

abstract interface class StreamingService {
  int beginGeneration();

  Stream<StreamEvent> streamReply({
    required String prompt,
    required String model,
    List<ChatTurn> history = const [],
    String? systemInstruction,
    ChatAttachment? attachment,
  });

  Future<void> cancel();
}
