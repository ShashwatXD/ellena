import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/conversation.dart';
import '../../core/models/message.dart';
import '../../core/models/message_status.dart';
import '../../data/api/api_exception.dart';
import '../../data/storage/chat_storage.dart';
import '../../data/streaming/message_stream.dart';
import '../../data/streaming/stream_event.dart';
import '../../data/streaming/streaming_service.dart';
import 'chat_state.dart';
import 'data_providers.dart';
import 'mock_stream_provider.dart';
import 'model_provider.dart';

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

class ChatNotifier extends Notifier<ChatState> {
  static const _streamPersistGap = Duration(milliseconds: 400);

  final Map<String, MessageStream> _streams = {};
  final Map<String, Timer> _persistDebounce = {};
  final Set<String> _titleRequestedIds = {};
  StreamingService? _liveService;

  ChatStorage get _storage => ref.read(chatStorageProvider);

  @override
  ChatState build() {
    ref.onDispose(() {
      final service = _liveService;
      _liveService = null;
      unawaited(service?.cancel());
      for (final stream in _streams.values) {
        unawaited(stream.cancel());
      }
      for (final timer in _persistDebounce.values) {
        timer.cancel();
      }
      _streams.clear();
      _persistDebounce.clear();
    });

    final loaded = _storage.load();
    unawaited(_storage.saveActiveConversationId(null));
    return loaded.when(
      success: (snapshot) => ChatState(
        conversations: snapshot.conversations,
        messagesByConversation: snapshot.messagesByConversation,
      ),
      failure: (error, stackTrace) => const ChatState(),
    );
  }

  Future<void> _persistConversation(String conversationId) async {
    final conversation = state.conversationById(conversationId);
    if (conversation == null) return;
    await _storage.saveConversation(conversation);
    await _storage.saveMessages(
      conversationId,
      state.messagesFor(conversationId),
    );
  }

  void _scheduleStreamPersist(String conversationId) {
    _persistDebounce[conversationId]?.cancel();
    _persistDebounce[conversationId] = Timer(_streamPersistGap, () {
      _persistDebounce.remove(conversationId);
      unawaited(_persistConversation(conversationId));
    });
  }

  Future<void> _flushPersist(String conversationId) async {
    _persistDebounce.remove(conversationId)?.cancel();
    await _persistConversation(conversationId);
  }

  String startConversation(String firstMessage) {
    final now = DateTime.now();
    final conversationId = 'c_${now.microsecondsSinceEpoch}';
    final title = _titleFrom(firstMessage);

    final conversation = Conversation(
      id: conversationId,
      title: title,
      updatedAt: now,
    );

    final userMessage = Message(
      id: 'm_${now.microsecondsSinceEpoch}',
      conversationId: conversationId,
      role: MessageRole.user,
      content: firstMessage.trim(),
      status: MessageStatus.complete,
      createdAt: now,
    );

    final assistantMessage = Message(
      id: 'm_${now.microsecondsSinceEpoch + 1}',
      conversationId: conversationId,
      role: MessageRole.assistant,
      content: '',
      status: MessageStatus.streaming,
      createdAt: now,
    );

    state = state.copyWith(
      conversations: [conversation, ...state.conversations],
      messagesByConversation: {
        ...state.messagesByConversation,
        conversationId: [userMessage, assistantMessage],
      },
      activeConversationId: conversationId,
    );
    unawaited(_flushPersist(conversationId));

    unawaited(
      _beginStream(
        conversationId: conversationId,
        messageId: assistantMessage.id,
        prompt: userMessage.content,
      ),
    );
    unawaited(
      _maybeGenerateTitle(conversationId, userMessage.content),
    );
    return conversationId;
  }

  void sendMessage(String conversationId, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    final existing = [...state.messagesFor(conversationId)];

    final userMessage = Message(
      id: 'm_${now.microsecondsSinceEpoch}',
      conversationId: conversationId,
      role: MessageRole.user,
      content: trimmed,
      status: MessageStatus.complete,
      createdAt: now,
    );

    final assistantMessage = Message(
      id: 'm_${now.microsecondsSinceEpoch + 1}',
      conversationId: conversationId,
      role: MessageRole.assistant,
      content: '',
      status: MessageStatus.streaming,
      createdAt: now,
    );

    final conversations = state.conversations.map((c) {
      if (c.id != conversationId) return c;
      return c.copyWith(updatedAt: now);
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    state = state.copyWith(
      conversations: conversations,
      messagesByConversation: {
        ...state.messagesByConversation,
        conversationId: [...existing, userMessage, assistantMessage],
      },
    );
    unawaited(_flushPersist(conversationId));

    unawaited(
      _beginStream(
        conversationId: conversationId,
        messageId: assistantMessage.id,
        prompt: trimmed,
      ),
    );
  }

  Future<void> stopStreaming(String conversationId) async {
    final messages = [...state.messagesFor(conversationId)];
    final index = messages.lastIndexWhere(
      (m) =>
          m.role == MessageRole.assistant &&
          m.status == MessageStatus.streaming,
    );
    if (index < 0) return;

    final messageId = messages[index].id;
    final stream = _streams.remove(messageId);

    await _liveService?.cancel();
    await stream?.cancel();

    messages[index] = messages[index].copyWith(
      status: MessageStatus.stopped,
      content: messages[index].content.isEmpty
          ? AppConstants.stoppedLabel
          : messages[index].content,
    );

    state = state.copyWith(
      messagesByConversation: {
        ...state.messagesByConversation,
        conversationId: messages,
      },
    );
    unawaited(_flushPersist(conversationId));
  }

  bool isStreaming(String conversationId) {
    return state.messagesFor(conversationId).any(
          (m) =>
              m.role == MessageRole.assistant &&
              m.status == MessageStatus.streaming,
        );
  }

  Future<void> deleteAllChats() async {
    await _liveService?.cancel();
    _liveService = null;
    for (final stream in _streams.values) {
      await stream.cancel();
    }
    for (final timer in _persistDebounce.values) {
      timer.cancel();
    }
    _streams.clear();
    _persistDebounce.clear();
    await _storage.clear();
    state = const ChatState();
  }

  void startNewChat() {
    state = state.copyWith(clearActiveConversationId: true);
  }

  void openConversation(String conversationId) {
    if (state.conversationById(conversationId) == null) return;
    state = state.copyWith(activeConversationId: conversationId);
  }

  void togglePin(String conversationId) {
    final conversation = state.conversationById(conversationId);
    if (conversation == null) return;

    final conversations = state.conversations.map((c) {
      if (c.id != conversationId) return c;
      return c.copyWith(isPinned: !c.isPinned);
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    state = state.copyWith(conversations: conversations);
    unawaited(
      _storage.saveConversation(
        conversation.copyWith(isPinned: !conversation.isPinned),
      ),
    );
  }

  void renameConversation(String conversationId, String title) {
    final cleaned = title.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return;
    final conversation = state.conversationById(conversationId);
    if (conversation == null) return;

    final updated = conversation.copyWith(title: cleaned);
    final conversations = state.conversations.map((c) {
      if (c.id != conversationId) return c;
      return updated;
    }).toList();

    state = state.copyWith(conversations: conversations);
    unawaited(_storage.saveConversation(updated));
  }

  Future<void> deleteConversation(String conversationId) async {
    _persistDebounce.remove(conversationId)?.cancel();
    final messages = state.messagesFor(conversationId);
    var streaming = false;
    for (final message in messages) {
      if (message.status != MessageStatus.streaming) continue;
      streaming = true;
      final stream = _streams.remove(message.id);
      await stream?.cancel();
    }
    if (streaming) await _liveService?.cancel();

    final conversations =
        state.conversations.where((c) => c.id != conversationId).toList();
    final messagesByConversation =
        Map<String, List<Message>>.from(state.messagesByConversation)
          ..remove(conversationId);

    final clearActive = state.activeConversationId == conversationId;
    state = state.copyWith(
      conversations: conversations,
      messagesByConversation: messagesByConversation,
      clearActiveConversationId: clearActive,
    );
    await _storage.deleteConversation(conversationId);
  }

  void retryMessage(String conversationId, String messageId) {
    final messages = [...state.messagesFor(conversationId)];
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index < 0) return;

    final failed = messages[index];
    if (failed.role != MessageRole.assistant ||
        failed.status != MessageStatus.failed) {
      return;
    }

    String? prompt;
    for (var i = index - 1; i >= 0; i--) {
      if (messages[i].role == MessageRole.user) {
        prompt = messages[i].content;
        break;
      }
    }
    if (prompt == null || prompt.isEmpty) return;

    messages[index] = failed.copyWith(
      content: '',
      status: MessageStatus.streaming,
      clearError: true,
    );
    state = state.copyWith(
      messagesByConversation: {
        ...state.messagesByConversation,
        conversationId: messages,
      },
    );
    unawaited(_flushPersist(conversationId));

    unawaited(
      _beginStream(
        conversationId: conversationId,
        messageId: messageId,
        prompt: prompt,
      ),
    );
  }

  Future<void> _beginStream({
    required String conversationId,
    required String messageId,
    required String prompt,
  }) async {
    final history = <({String role, String text})>[];
    for (final message in state.messagesFor(conversationId)) {
      if (message.id == messageId) continue;
      if (message.content.isEmpty) continue;
      if (message.status != MessageStatus.complete &&
          message.status != MessageStatus.stopped) {
        continue;
      }
      history.add((
        role: message.role == MessageRole.assistant ? 'assistant' : 'user',
        text: message.content,
      ));
    }
    if (history.isNotEmpty && history.last.role == 'user') {
      history.removeLast();
    }

    final service = ref.read(streamingServiceProvider);
    _liveService = service;
    final model = ref.read(selectedModelProvider).id;

    await _streams.remove(messageId)?.cancel();
    final generation = service.beginGeneration();
    final live = MessageStream(generation);
    _streams[messageId] = live;

    try {
      live.subscription = service
          .streamReply(prompt: prompt, model: model, history: history)
          .listen(
        (event) => _onStreamEvent(conversationId, messageId, event),
        onError: (Object error, StackTrace stackTrace) {
          if (!_owns(messageId, generation)) return;
          unawaited(_failStream(conversationId, messageId, error));
        },
        onDone: () {
          if (!_owns(messageId, generation)) return;
          unawaited(_completeStream(conversationId, messageId));
        },
        cancelOnError: true,
      );
    } catch (error) {
      if (!_owns(messageId, generation)) return;
      await _failStream(conversationId, messageId, error);
    }
  }

  bool _owns(String messageId, int generation) =>
      _streams[messageId]?.generation == generation;

  void _onStreamEvent(
    String conversationId,
    String messageId,
    StreamEvent event,
  ) {
    final live = _streams[messageId];
    if (live == null || !live.accept(event)) return;

    if (event.isText) {
      final text = event.text;
      if (text == null || text.isEmpty) return;
      _appendChunk(conversationId, messageId, text);
      return;
    }

    if (!event.isContentPolicy) return;
    final value = event.metaValue;
    if (value == null || value.isEmpty) return;
    final current = state.messagesFor(conversationId);
    final index = current.indexWhere((m) => m.id == messageId);
    if (index < 0 || current[index].content.isNotEmpty) return;
    unawaited(
      _failStream(
        conversationId,
        messageId,
        ApiException.contentPolicy(reason: value),
      ),
    );
  }

  void _appendChunk(String conversationId, String messageId, String chunk) {
    if (!_streams.containsKey(messageId)) return;

    final messages = [...state.messagesFor(conversationId)];
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index < 0) return;
    if (messages[index].status != MessageStatus.streaming) return;

    messages[index] = messages[index].copyWith(
      content: '${messages[index].content}$chunk',
    );
    state = state.copyWith(
      messagesByConversation: {
        ...state.messagesByConversation,
        conversationId: messages,
      },
    );
    _scheduleStreamPersist(conversationId);
  }

  Future<void> _completeStream(String conversationId, String messageId) async {
    _streams.remove(messageId);

    final messages = [...state.messagesFor(conversationId)];
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index < 0) return;
    if (messages[index].status != MessageStatus.streaming) return;

    final content = messages[index].content;
    if (content.isEmpty) {
      messages[index] = messages[index].copyWith(
        status: MessageStatus.failed,
        error: AppConstants.geminiRequestFailed,
      );
    } else {
      messages[index] =
          messages[index].copyWith(status: MessageStatus.complete);
    }
    state = state.copyWith(
      messagesByConversation: {
        ...state.messagesByConversation,
        conversationId: messages,
      },
    );
    unawaited(_flushPersist(conversationId));
  }

  Future<void> _maybeGenerateTitle(
    String conversationId,
    String firstUserMessage,
  ) async {
    if (ref.read(useFakeStreamProvider)) return;
    if (!_titleRequestedIds.add(conversationId)) return;

    final provisional = _titleFrom(firstUserMessage);
    final title =
        await ref.read(geminiTitleProvider).generateTitle(firstUserMessage);
    if (title == null || title.isEmpty) return;

    final current = state.conversationById(conversationId);
    if (current == null) return;
    if (current.title != provisional) return;

    renameConversation(conversationId, title);
  }

  Future<void> _failStream(
    String conversationId,
    String messageId,
    Object error,
  ) async {
    _streams.remove(messageId);

    final messages = [...state.messagesFor(conversationId)];
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index < 0) return;
    if (messages[index].status != MessageStatus.streaming) return;

    final mapped = ApiException.fromObject(error);
    final isCancel = mapped.isCancel;

    messages[index] = messages[index].copyWith(
      status: isCancel ? MessageStatus.stopped : MessageStatus.failed,
      error: isCancel ? null : mapped.message,
      errorDetail: isCancel ? null : mapped.detail,
      clearError: isCancel,
    );
    state = state.copyWith(
      messagesByConversation: {
        ...state.messagesByConversation,
        conversationId: messages,
      },
    );
    unawaited(_flushPersist(conversationId));
  }

  String _titleFrom(String text) {
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.length <= 36) return cleaned;
    return '${cleaned.substring(0, 36)}...';
  }
}
