import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/conversation.dart';
import '../../core/models/message.dart';
import '../../core/models/message_status.dart';
import 'chat_state.dart';

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

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

    _simulateStream(conversationId, assistantMessage.id);
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

    _simulateStream(conversationId, assistantMessage.id);
  }

  void stopStreaming(String conversationId) {
    final messages = [...state.messagesFor(conversationId)];
    final index = messages.lastIndexWhere(
      (m) => m.role == MessageRole.assistant && m.status == MessageStatus.streaming,
    );
    if (index < 0) return;

    messages[index] = messages[index].copyWith(
      status: MessageStatus.stopped,
      content: messages[index].content.isEmpty
          ? 'Stopped'
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

  Future<void> _simulateStream(String conversationId, String messageId) async {
    const chunks = [
      'Here\'s a starting point. ',
      'We\'ll wire real Gemini streaming next — ',
      'for now this is a local placeholder so the UI flow is testable.',
    ];

    for (final chunk in chunks) {
      await Future<void>.delayed(const Duration(milliseconds: 280));
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

  String _titleFrom(String text) {
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.length <= 36) return cleaned;
    return '${cleaned.substring(0, 36)}…';
  }
}
