import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/message_status.dart';
import '../providers/providers.dart';
import '../theme/app_breakpoints.dart';
import '../theme/app_spacing.dart';
import '../widgets/chat_composer.dart';
import '../widgets/ellena_app_bar.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chat = ref.watch(chatProvider);
    final conversation = chat.conversationById(widget.conversationId);
    final messages = chat.messagesFor(widget.conversationId);
    final streaming = messages.any(
      (m) =>
          m.role == MessageRole.assistant &&
          m.status == MessageStatus.streaming,
    );
    final pagePad = AppBreakpoints.pagePadding(context);

    ref.listen(chatProvider, (prev, next) {
      final nextMessages = next.messagesFor(widget.conversationId);
      final prevMessages = prev?.messagesFor(widget.conversationId) ?? const [];
      if (nextMessages.length != prevMessages.length ||
          (nextMessages.isNotEmpty &&
              prevMessages.isNotEmpty &&
              nextMessages.last.content != prevMessages.last.content)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: EllenaAppBar(
        title: Text(
          conversation?.title ?? AppConstants.chatFallbackTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? SafeArea(
                    top: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: pagePad),
                        child: Text(
                          AppConstants.noMessages,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      pagePad,
                      AppSpacing.sm,
                      pagePad,
                      AppSpacing.lg,
                    ),
                    itemCount: messages.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return MessageBubble(message: messages[index]);
                    },
                  ),
          ),
          ChatComposer(
            isStreaming: streaming,
            hintText: AppConstants.composerHint,
            onSend: (text) {
              ref
                  .read(chatProvider.notifier)
                  .sendMessage(widget.conversationId, text);
            },
            onStop: () {
              ref
                  .read(chatProvider.notifier)
                  .stopStreaming(widget.conversationId);
            },
          ),
        ],
      ),
    );
  }
}
