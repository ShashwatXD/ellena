import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/chat_attachment.dart';

final composerAttachmentProvider =
    NotifierProvider<ComposerAttachmentNotifier, ChatAttachment?>(
  ComposerAttachmentNotifier.new,
);

class ComposerAttachmentNotifier extends Notifier<ChatAttachment?> {
  @override
  ChatAttachment? build() => null;

  void set(ChatAttachment attachment) => state = attachment;

  void clear() => state = null;
}
