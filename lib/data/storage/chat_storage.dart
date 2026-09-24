import '../../core/models/conversation.dart';
import '../../core/models/message.dart';
import '../../core/models/message_status.dart';
import 'app_storage.dart';
import 'chat_snapshot.dart';
import 'storage_keys.dart';
import 'storage_service.dart';

/// Hive persistence for conversations + messages.
class ChatStorage {
  ChatStorage({StorageService? storage})
      : _storage = storage ?? StorageService.instance;

  final StorageService _storage;

  ChatSnapshot load() {
    final conversations = <Conversation>[];
    for (final key in _storage.keys(boxName: StorageKeys.conversationsBox)) {
      final raw = _storage.get<dynamic>(
        key.toString(),
        boxName: StorageKeys.conversationsBox,
      );
      if (raw is Map) {
        conversations.add(Conversation.fromJson(raw));
      }
    }
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final messagesByConversation = <String, List<Message>>{};
    for (final conversation in conversations) {
      messagesByConversation[conversation.id] =
          _loadMessages(conversation.id);
    }

    final activeId =
        AppStorage.read<String>(StorageKeys.activeConversationId);
    final activeOk =
        activeId != null && conversations.any((c) => c.id == activeId);

    return ChatSnapshot(
      conversations: conversations,
      messagesByConversation: messagesByConversation,
      activeConversationId: activeOk ? activeId : null,
    );
  }

  List<Message> _loadMessages(String conversationId) {
    final raw = _storage.get<dynamic>(
      conversationId,
      boxName: StorageKeys.messagesBox,
    );
    if (raw is! List) return const [];

    final messages = <Message>[];
    for (final item in raw) {
      if (item is! Map) continue;
      var message = Message.fromJson(item);
      if (message.status == MessageStatus.streaming ||
          message.status == MessageStatus.sending) {
        message = message.content.isEmpty
            ? message.copyWith(
                status: MessageStatus.failed,
                error: 'Interrupted',
              )
            : message.copyWith(
                status: MessageStatus.stopped,
                clearError: true,
              );
      }
      messages.add(message);
    }
    return messages;
  }

  Future<void> saveConversation(Conversation conversation) {
    return _storage.set(
      conversation.id,
      conversation.toJson(),
      boxName: StorageKeys.conversationsBox,
    );
  }

  Future<void> saveMessages(String conversationId, List<Message> messages) {
    return _storage.set(
      conversationId,
      messages.map((m) => m.toJson()).toList(),
      boxName: StorageKeys.messagesBox,
    );
  }

  Future<void> saveActiveConversationId(String? id) {
    if (id == null) {
      return AppStorage.remove(StorageKeys.activeConversationId);
    }
    return AppStorage.save(StorageKeys.activeConversationId, id);
  }

  Future<void> clear() async {
    await _storage.clear(StorageKeys.conversationsBox);
    await _storage.clear(StorageKeys.messagesBox);
    await AppStorage.remove(StorageKeys.activeConversationId);
  }
}
