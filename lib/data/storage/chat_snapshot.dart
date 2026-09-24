import '../../core/models/conversation.dart';
import '../../core/models/message.dart';

class ChatSnapshot {
  const ChatSnapshot({
    this.conversations = const [],
    this.messagesByConversation = const {},
    this.activeConversationId,
  });

  final List<Conversation> conversations;
  final Map<String, List<Message>> messagesByConversation;
  final String? activeConversationId;
}
