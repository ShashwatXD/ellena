class HistoryOp {
  const HistoryOp({
    required this.id,
    required this.chatId,
    required this.kind,
    required this.order,
    this.body,
  });

  final String id;
  final String chatId;
  final String kind;
  final int order;
  final Map<String, dynamic>? body;

  Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'kind': kind,
        'order': order,
        'body': body,
      };

  factory HistoryOp.fromJson(Map<dynamic, dynamic> json) {
    final raw = json['body'];
    return HistoryOp(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      kind: json['kind'] as String,
      order: (json['order'] as num).toInt(),
      body: raw is Map ? Map<String, dynamic>.from(raw) : null,
    );
  }
}

abstract final class HistoryOpKind {
  static const String rename = 'rename';
  static const String pin = 'pin';
  static const String delete = 'delete';
  static const String send = 'send';
  static const String put = 'put';
}
