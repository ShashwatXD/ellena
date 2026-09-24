class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    required this.updatedAt,
    this.isPinned = false,
  });

  final String id;
  final String title;
  final DateTime updatedAt;
  final bool isPinned;

  Conversation copyWith({
    String? title,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return Conversation(
      id: id,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'updatedAt': updatedAt.toIso8601String(),
        'isPinned': isPinned,
      };

  factory Conversation.fromJson(Map<dynamic, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }
}
