import '../../core/models/conversation.dart';
import '../../core/models/message.dart';
import '../../core/utils/uuid.dart';
import '../cache/history_choice.dart';
import '../network/api_repository.dart';
import '../storage/chat_storage.dart';
import '../storage/install_id.dart';
import 'history_op.dart';
import 'history_queue.dart';

class HistorySync {
  HistorySync({
    required ApiRepository api,
    required ChatStorage storage,
    HistoryQueue? queue,
  })  : _api = api,
        _storage = storage,
        _queue = queue ?? HistoryQueue();

  final ApiRepository _api;
  final ChatStorage _storage;
  final HistoryQueue _queue;
  Future<void> _tail = Future<void>.value();

  Future<void> commit(String chatId, String kind) {
    return _serialized(() async {
      await _enqueue(chatId, kind);
      await _flushUnlocked();
    });
  }

  Future<void> discard() => _serialized(_queue.clear);

  Future<Set<String>?> sync() {
    return _serialized(() async {
      await _flushUnlocked();
      return _pullUnlocked();
    });
  }

  Future<T> _serialized<T>(Future<T> Function() action) {
    final run = _tail.then((_) => action());
    _tail = run.then((_) {}, onError: (_) {});
    return run;
  }

  Future<void> _enqueue(String chatId, String kind) async {
    final installId = InstallId.read();
    if (!_api.hasHistory || installId == null) return;
    Map<String, dynamic>? body;
    if (kind != HistoryOpKind.delete) {
      final conversation = _storage.readConversation(chatId);
      if (conversation == null) return;
      body = _body(conversation, _storage.loadMessages(chatId));
    }
    await _queue.add(
      HistoryOp(
        id: Uuid.v4(),
        chatId: chatId,
        kind: kind,
        order: DateTime.now().microsecondsSinceEpoch,
        body: body,
      ),
    );
  }

  Future<void> _flushUnlocked() async {
    final installId = InstallId.read();
    if (!_api.hasHistory || installId == null) return;
    for (final op in _queue.read()) {
      final sent = op.kind == HistoryOpKind.delete
          ? await _api.deleteHistoryChat(
              installId: installId,
              chatId: op.chatId,
              opId: op.id,
            )
          : await _api.putHistoryChat(
              installId: installId,
              chatId: op.chatId,
              body: {
                ...?op.body,
                'opId': op.id,
                'opKind': op.kind,
              },
            );
      if (!sent.isSuccess || sent.valueOrNull != true) return;
      await _queue.ack(op.id);
    }
  }

  Future<Set<String>?> _pullUnlocked() async {
    final installId = InstallId.read();
    if (!_api.hasHistory || installId == null) return null;
    final fetched = await _api.fetchHistory(installId);
    final raw = fetched.valueOrNull?['chats'];
    if (raw is! List) return null;
    final busy = _queue.chatIds();
    final changed = <String>{};
    final remoteIds = <String>{};
    for (final item in raw) {
      if (item is! Map) continue;
      final remoteChat = Conversation.fromJson(item);
      remoteIds.add(remoteChat.id);
      if (busy.contains(remoteChat.id)) continue;
      final local = _storage.readConversation(remoteChat.id);
      if (local != null && local.updatedAt == remoteChat.updatedAt) continue;
      final chosen = local == null
          ? remoteChat
          : preferLater(local: local, remote: remoteChat);
      if (local != null && !identical(chosen, remoteChat)) {
        await _api.putHistoryChat(
          installId: installId,
          chatId: local.id,
          body: _body(local, _storage.loadMessages(local.id)),
        );
        continue;
      }
      await _storage.saveConversation(chosen);
      await _storage.saveMessages(chosen.id, _messagesOf(item));
      changed.add(chosen.id);
    }
    final local = _storage.loadConversationList().valueOrNull ?? const [];
    for (final conversation in local) {
      if (remoteIds.contains(conversation.id) || busy.contains(conversation.id)) {
        continue;
      }
      await _api.putHistoryChat(
        installId: installId,
        chatId: conversation.id,
        body: _body(conversation, _storage.loadMessages(conversation.id)),
      );
    }
    return changed;
  }

  Map<String, dynamic> _body(
    Conversation conversation,
    List<Message> messages,
  ) {
    return {
      ...conversation.toJson(),
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }

  List<Message> _messagesOf(Map<dynamic, dynamic> json) {
    final raw = json['messages'];
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map) Message.fromJson(item),
    ];
  }
}
