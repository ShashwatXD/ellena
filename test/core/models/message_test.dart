import 'package:ellena/core/models/chat_attachment.dart';
import 'package:ellena/core/models/conversation.dart';
import 'package:ellena/core/models/message.dart';
import 'package:ellena/core/models/message_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final created = DateTime.utc(2026, 9, 25, 12);

  Message sample() {
    return Message(
      id: 'm1',
      conversationId: 'c1',
      role: MessageRole.assistant,
      content: 'hello',
      status: MessageStatus.failed,
      createdAt: created,
      error: 'Interrupted',
      errorDetail: 'HTTP 500',
    );
  }

  test('message json round-trips role, status, and errors', () {
    final restored = Message.fromJson(sample().toJson());

    expect(restored.id, 'm1');
    expect(restored.role, MessageRole.assistant);
    expect(restored.status, MessageStatus.failed);
    expect(restored.error, 'Interrupted');
    expect(restored.errorDetail, 'HTTP 500');
    expect(restored.createdAt, created);
  });

  test('clearError drops both error fields', () {
    final cleared = sample().copyWith(
      status: MessageStatus.streaming,
      clearError: true,
    );

    expect(cleared.content, 'hello');
    expect(cleared.status, MessageStatus.streaming);
    expect(cleared.error, isNull);
    expect(cleared.errorDetail, isNull);
  });

  test('attachment json round-trips and marks images', () {
    const file = ChatAttachment(
      name: 'notes.pdf',
      mimeType: 'application/pdf',
      path: '/tmp/notes.pdf',
      sizeBytes: 12,
    );
    const image = ChatAttachment(
      name: 'shot.png',
      mimeType: 'image/png',
      path: '/tmp/shot.png',
      sizeBytes: 4,
    );

    expect(file.isImage, isFalse);
    expect(image.isImage, isTrue);
    expect(
      Message.fromJson(sample().copyWith().toJson()..['attachment'] = file.toJson())
          .attachment
          ?.name,
      'notes.pdf',
    );
  });

  test('conversation json defaults pin to false', () {
    final restored = Conversation.fromJson({
      'id': 'c1',
      'title': 'Notes',
      'updatedAt': created.toIso8601String(),
    });

    expect(restored.isPinned, isFalse);
    expect(restored.copyWith(isPinned: true).toJson()['isPinned'], isTrue);
  });
}
