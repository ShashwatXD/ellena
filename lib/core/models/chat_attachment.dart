class ChatAttachment {
  const ChatAttachment({
    required this.name,
    required this.mimeType,
    required this.path,
    required this.sizeBytes,
  });

  final String name;
  final String mimeType;
  final String path;
  final int sizeBytes;

  bool get isImage => mimeType.startsWith('image/');

  Map<String, dynamic> toJson() => {
        'name': name,
        'mimeType': mimeType,
        'path': path,
        'sizeBytes': sizeBytes,
      };

  factory ChatAttachment.fromJson(Map<dynamic, dynamic> json) {
    return ChatAttachment(
      name: json['name'] as String? ?? 'file',
      mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
      path: json['path'] as String? ?? '',
      sizeBytes: json['sizeBytes'] as int? ?? 0,
    );
  }
}
