import 'package:ellena/core/models/conversation.dart';
import 'package:ellena/core/models/message.dart';
import 'package:ellena/core/models/message_status.dart';
import 'package:ellena/presentation/providers/chat_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final updatedAt = DateTime.utc(2026, 9, 25);

  ChatState state() {
    return ChatState(
      conversations: [
        Conversation(id: 'a', title: 'A', updatedAt: updatedAt),
      ],
      messagesByConversation: {
        'a': [
          Message(
            id: 'm1',
            conversationId: 'a',
            role: MessageRole.user,
            content: 'hi',
            status: MessageStatus.complete,
            createdAt: updatedAt,
          ),
        ],
      },
      activeConversationId: 'a',
    );
  }

  test('lookup misses return an empty message list', () {
    expect(state().messagesFor('missing'), isEmpty);
    expect(state().conversationById('a')?.title, 'A');
    expect(state().conversationById('missing'), isNull);
  });

  test('clearing the active conversation drops the id', () {
    final cleared = state().copyWith(clearActiveConversationId: true);

    expect(cleared.activeConversationId, isNull);
    expect(cleared.conversations, hasLength(1));
  });
}
