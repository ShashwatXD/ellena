import 'dart:async';

import '../../core/models/conversation.dart';
import '../../core/models/message.dart';
import '../storage/chat_storage.dart';
import 'chat_remote.dart';

class ChatCache {
  ChatCache({
    required ChatStorage storage,
    required ChatRemote remote,
  })  : _storage = storage,
        _remote = remote;

  static const messageWindowLimit = 1;

  final ChatStorage _storage;
  final ChatRemote _remote;

  List<Conversation>? _list;
  final Map<String, Conversation> _records = {};
  final Map<String, List<Message>> _messages = {};
  final Set<String> _protected = {};

  Map<String, List<Message>> windows() => {
        for (final entry in _messages.entries) entry.key: entry.value,
      };

  List<Conversation> readConversations() {
    final cached = _list;
    if (cached != null) return cached;

    final loaded = _storage.loadConversationList();
    if (loaded.isFailure) return const [];
    final list = loaded.valueOrNull ?? const <Conversation>[];
    _list = list;
    _records
      ..clear()
      ..addAll({for (final conversation in list) conversation.id: conversation});
    return list;
  }

  Conversation? readConversation(String id) {
    final cached = _records[id];
    if (cached != null) return cached;

    final local = _storage.readConversation(id);
    if (local != null) {
      _records[id] = local;
      return local;
    }

    final fetched = _remote.conversation(id).valueOrNull;
    if (fetched == null) return null;
    _records[id] = fetched;
    final list = _list;
    if (list != null) {
      _list = [...list.where((item) => item.id != id), fetched]
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    unawaited(_storage.saveConversation(fetched));
    return fetched;
  }

  List<Message> readMessages(String conversationId) {
    final cached = _messages[conversationId];
    if (cached != null) return cached;

    if (_storage.hasMessages(conversationId)) {
      final loaded = _storage.loadMessages(conversationId);
      holdMessages(conversationId, loaded);
      return loaded;
    }

    final fetched = _remote.messages(conversationId).valueOrNull;
    if (fetched == null) return const [];
    holdMessages(conversationId, fetched);
    unawaited(_storage.saveMessages(conversationId, fetched));
    return fetched;
  }

  void holdMessages(String conversationId, List<Message> messages) {
    _messages[conversationId] = messages;
    _evictExcept(conversationId);
  }

  void protect(String conversationId) => _protected.add(conversationId);

  void unprotect(String conversationId, {String? keep}) {
    _protected.remove(conversationId);
    if (keep != null) _evictExcept(keep);
  }

  void invalidateRecord(String conversationId) {
    _records.remove(conversationId);
  }

  void invalidateList() {
    _list = null;
  }

  void invalidateMessages(String conversationId) {
    _messages.remove(conversationId);
  }

  void invalidateAll() {
    _list = null;
    _records.clear();
    _messages.clear();
    _protected.clear();
  }

  void _evictExcept(String current) {
    final keep = {..._protected};
    if (messageWindowLimit > 0) keep.add(current);
    final drop = _messages.keys.where((id) => !keep.contains(id)).toList();
    for (final id in drop) {
      _messages.remove(id);
    }
  }
}
