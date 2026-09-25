import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_streaming_text_markdown/flutter_streaming_text_markdown.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/message.dart';
import '../../../core/models/message_status.dart';
import '../../providers/providers.dart';
import '../../theme/app_breakpoints.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../clipboard_copy.dart';

part 'user_bubble.dart';
part 'assistant_bubble.dart';
part 'markdown_code_block.dart';
part 'assistant_actions.dart';
part 'failure_actions.dart';
part 'loading_dots.dart';
part 'streaming_caret.dart';
part 'status_chip.dart';

class MessageBubble extends ConsumerWidget {
  const MessageBubble({
    super.key,
    required this.conversationId,
    required this.messageId,
  });

  final String conversationId;
  final String messageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(
      chatProvider.select((state) {
        for (final item in state.messagesFor(conversationId)) {
          if (item.id == messageId) return item;
        }
        return null;
      }),
    );
    if (message == null) return const SizedBox.shrink();

    final canRetry = ref.watch(
      chatProvider.select((state) {
        final messages = state.messagesFor(conversationId);
        if (messages.isEmpty) return false;
        final last = messages.last;
        return last.id == messageId && last.status == MessageStatus.failed;
      }),
    );

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isUser = message.role == MessageRole.user;
    final maxWidth = MediaQuery.sizeOf(context).width *
        AppBreakpoints.messageMaxFraction(isUser: isUser);
    final motion = AppMotion.of(context, AppMotion.normal);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: motion,
      curve: AppMotion.standard,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 8),
            child: child,
          ),
        );
      },
      child: isUser
          ? _UserBubble(
              message: message,
              maxWidth: maxWidth,
              theme: theme,
              colors: colors,
            )
          : _AssistantBubble(
              message: message,
              maxWidth: maxWidth,
              theme: theme,
              colors: colors,
              onRetry: canRetry
                  ? () {
                      HapticFeedback.lightImpact();
                      ref.read(chatProvider.notifier).retryMessage(
                            conversationId,
                            messageId,
                          );
                    }
                  : null,
            ),
    );
  }
}
