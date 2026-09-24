import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/conversation.dart';
import '../../core/models/message.dart';
import '../../core/models/message_status.dart';
import 'chat_state.dart';
import 'data_providers.dart';
import 'model_provider.dart';

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

class ChatNotifier extends Notifier<ChatState> {
  final Map<String, StreamSubscription<String>> _subscriptions = {};
  final Set<String> _activeMessageIds = {};

  @override
  ChatState build() {
    ref.onDispose(() {
      for (final subscription in _subscriptions.values) {
        unawaited(subscription.cancel());
      }
      _subscriptions.clear();
      _activeMessageIds.clear();
    });
    return const ChatState();
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
    );

    unawaited(
      _beginStream(
        conversationId: conversationId,
        messageId: assistantMessage.id,
        prompt: userMessage.content,
      ),
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
    _activeMessageIds.remove(messageId);

    await ref.read(streamingServiceProvider).cancel();
    final subscription = _subscriptions.remove(messageId);
    await subscription?.cancel();

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
  }

  bool isStreaming(String conversationId) {
    return state.messagesFor(conversationId).any(
          (m) =>
              m.role == MessageRole.assistant &&
              m.status == MessageStatus.streaming,
        );
  }

  Future<void> deleteAllChats() async {
    await ref.read(streamingServiceProvider).cancel();
    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _activeMessageIds.clear();
    state = const ChatState();
  }

  Future<void> _beginStream({
    required String conversationId,
    required String messageId,
    required String prompt,
  }) async {
    _activeMessageIds.add(messageId);

    final prior = state
        .messagesFor(conversationId)
        .where(
          (m) =>
              m.id != messageId &&
              m.status == MessageStatus.complete &&
              m.content.isNotEmpty,
        )
        .toList();
    if (prior.isNotEmpty && prior.last.role == MessageRole.user) {
      prior.removeLast();
    }

    final history = prior
        .map(
          (m) => (
            role: m.role == MessageRole.assistant ? 'assistant' : 'user',
            text: m.content,
          ),
        )
        .toList();

    final service = ref.read(streamingServiceProvider);
    final model = ref.read(selectedModelProvider).id;

    try {
      final subscription = service
          .streamReply(prompt: prompt, model: model, history: history)
          .listen(
        (chunk) {
          if (!_activeMessageIds.contains(messageId)) return;
          _appendChunk(conversationId, messageId, chunk);
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!_activeMessageIds.contains(messageId)) return;
          unawaited(_failStream(conversationId, messageId, error));
        },
        onDone: () {
          if (!_activeMessageIds.contains(messageId)) return;
          unawaited(_completeStream(conversationId, messageId));
        },
        cancelOnError: true,
      );
      _subscriptions[messageId] = subscription;
    } catch (error) {
      if (!_activeMessageIds.contains(messageId)) return;
      await _failStream(conversationId, messageId, error);
    }
  }

  void _appendChunk(String conversationId, String messageId, String chunk) {
    if (!_activeMessageIds.contains(messageId)) return;

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
  }

  Future<void> _completeStream(String conversationId, String messageId) async {
    _activeMessageIds.remove(messageId);
    _subscriptions.remove(messageId);

    final messages = [...state.messagesFor(conversationId)];
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index < 0) return;
    if (messages[index].status != MessageStatus.streaming) return;

    messages[index] = messages[index].copyWith(status: MessageStatus.complete);
    state = state.copyWith(
      messagesByConversation: {
        ...state.messagesByConversation,
        conversationId: messages,
      },
    );
  }

  Future<void> _failStream(
    String conversationId,
    String messageId,
    Object error,
  ) async {
    _activeMessageIds.remove(messageId);
    _subscriptions.remove(messageId);

    final messages = [...state.messagesFor(conversationId)];
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index < 0) return;
    if (messages[index].status != MessageStatus.streaming) return;

    final isCancel =
        error is DioException && error.type == DioExceptionType.cancel;
    final message = isCancel
        ? AppConstants.stoppedLabel
        : error is DioException
            ? AppConstants.geminiRequestFailed
            : AppConstants.genericError;

    messages[index] = messages[index].copyWith(
      status: isCancel ? MessageStatus.stopped : MessageStatus.failed,
      error: isCancel ? null : message,
      content: messages[index].content.isEmpty
          ? message
          : messages[index].content,
    );
    state = state.copyWith(
      messagesByConversation: {
        ...state.messagesByConversation,
        conversationId: messages,
      },
    );
  }

  String _titleFrom(String text) {
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.length <= 36) return cleaned;
    return '${cleaned.substring(0, 36)}…';
  }
}
