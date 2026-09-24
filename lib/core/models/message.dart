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

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'role': role.name,
        'content': content,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'error': error,
      };

  factory Message.fromJson(Map<dynamic, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      role: MessageRole.values.byName(json['role'] as String),
      content: json['content'] as String? ?? '',
      status: MessageStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      error: json['error'] as String?,
    );
  }
}
