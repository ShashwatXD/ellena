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
}
