import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/message_status.dart';
import '../../../common_widgets/chat_composer/chat_composer.dart';
import '../../../providers/providers.dart';

class ChatComposerSlot extends ConsumerWidget {
  const ChatComposerSlot({super.key, required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streaming = ref.watch(
      chatProvider.select(
        (state) => state.messagesFor(conversationId).any(
              (m) =>
                  m.role == MessageRole.assistant &&
                  m.status == MessageStatus.streaming,
            ),
      ),
    );

    return ChatComposer(
      isStreaming: streaming,
      onSend: (text) {
        ref.read(chatProvider.notifier).sendMessage(conversationId, text);
      },
      onStop: () {
        ref.read(chatProvider.notifier).stopStreaming(conversationId);
      },
    );
  }
}
