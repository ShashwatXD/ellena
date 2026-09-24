import '../../core/models/conversation.dart';
import '../../core/models/message.dart';

class ChatState {
  const ChatState({
    this.conversations = const [],
    this.messagesByConversation = const {},
    this.activeConversationId,
  });

  final List<Conversation> conversations;
  final Map<String, List<Message>> messagesByConversation;
  final String? activeConversationId;

  List<Message> messagesFor(String conversationId) {
    return messagesByConversation[conversationId] ?? const [];
  }

  Conversation? conversationById(String id) {
    for (final c in conversations) {
      if (c.id == id) return c;
    }
    return null;
  }

  ChatState copyWith({
    List<Conversation>? conversations,
    Map<String, List<Message>>? messagesByConversation,
    String? activeConversationId,
    bool clearActiveConversationId = false,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      messagesByConversation:
          messagesByConversation ?? this.messagesByConversation,
      activeConversationId: clearActiveConversationId
          ? null
          : (activeConversationId ?? this.activeConversationId),
    );
  }
}
