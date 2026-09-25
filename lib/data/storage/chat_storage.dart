import '../../core/models/conversation.dart';
import '../../core/models/message.dart';
import '../../core/models/message_status.dart';
import '../../core/result/result.dart';
import 'chat_snapshot.dart';
import 'storage_keys.dart';
import 'storage_service.dart';

/// Hive persistence for conversations + messages.
class ChatStorage {
  ChatStorage({StorageService? storage})
      : _storage = storage ?? StorageService.instance;

  final StorageService _storage;

  Result<ChatSnapshot> load() {
    try {
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

      return Success(
        ChatSnapshot(
          conversations: conversations,
          messagesByConversation: messagesByConversation,
        ),
      );
    } catch (error, stackTrace) {
      return Failure(error, stackTrace);
    }
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

  Future<Result<bool>> saveConversation(Conversation conversation) {
    return _run(() async {
      await _storage.set(
        conversation.id,
        conversation.toJson(),
        boxName: StorageKeys.conversationsBox,
      );
      return true;
    });
  }

  Future<Result<bool>> saveMessages(
    String conversationId,
    List<Message> messages,
  ) {
    return _run(() async {
      await _storage.set(
        conversationId,
        messages.map((m) => m.toJson()).toList(),
        boxName: StorageKeys.messagesBox,
      );
      return true;
    });
  }

  Future<Result<bool>> deleteConversation(String conversationId) {
    return _run(() async {
      await _storage.delete(
        conversationId,
        boxName: StorageKeys.conversationsBox,
      );
      await _storage.delete(
        conversationId,
        boxName: StorageKeys.messagesBox,
      );
      return true;
    });
  }

  Future<Result<bool>> clear() {
    return _run(() async {
      await _storage.clear(StorageKeys.conversationsBox);
      await _storage.clear(StorageKeys.messagesBox);
      return true;
    });
  }

  Future<Result<bool>> _run(Future<bool> Function() action) async {
    try {
      return Success(await action());
    } catch (error, stackTrace) {
      return Failure(error, stackTrace);
    }
  }
}
