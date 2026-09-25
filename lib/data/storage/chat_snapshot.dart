import '../../core/models/conversation.dart';
import '../../core/models/message.dart';

class ChatSnapshot {
  const ChatSnapshot({
    this.conversations = const [],
    this.messagesByConversation = const {},
  });

  final List<Conversation> conversations;
  final Map<String, List<Message>> messagesByConversation;
}
