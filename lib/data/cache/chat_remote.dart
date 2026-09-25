import '../../core/models/conversation.dart';
import '../../core/models/message.dart';
import '../../core/result/result.dart';

abstract class ChatRemote {
  Result<Conversation?> conversation(String id);

  Result<List<Message>?> messages(String conversationId);
}

class UnavailableChatRemote implements ChatRemote {
  const UnavailableChatRemote();

  @override
  Result<Conversation?> conversation(String id) => const Success(null);

  @override
  Result<List<Message>?> messages(String conversationId) => const Success(null);
}
