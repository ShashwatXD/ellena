import 'message_status.dart';

class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.status,
    required this.createdAt,
    this.error,
  });

  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final MessageStatus status;
  final DateTime createdAt;
  final String? error;

  Message copyWith({
    String? content,
    MessageStatus? status,
    String? error,
    bool clearError = false,
  }) {
    return Message(
      id: id,
      conversationId: conversationId,
      role: role,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
