import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/message_status.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_shell.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chat = ref.watch(chatProvider);
    final conversation = chat.conversationById(conversationId);
    final messages = chat.messagesFor(conversationId);
    final streaming = messages.any(
      (m) =>
          m.role == MessageRole.assistant && m.status == MessageStatus.streaming,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Menu',
          onPressed: () => ChatShell.scaffoldKey.currentState?.openDrawer(),
          style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
          icon: const Icon(Icons.menu_rounded),
        ),
        title: Text(
          conversation?.title ?? 'Chat',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: messages.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return MessageBubble(message: messages[index]);
                    },
                  ),
          ),
          ChatComposer(
            isStreaming: streaming,
            hintText: AppConstants.composerHint,
            onSend: (text) {
              ref.read(chatProvider.notifier).sendMessage(conversationId, text);
            },
            onStop: () {
              ref.read(chatProvider.notifier).stopStreaming(conversationId);
            },
          ),
        ],
      ),
    );
  }
}
