import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_streaming_text_markdown/flutter_streaming_text_markdown.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/message.dart';
import '../../../core/models/message_status.dart';
import '../../providers/providers.dart';
import '../../theme/app_breakpoints.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_snack_bar.dart';

part 'user_bubble.dart';
part 'assistant_bubble.dart';
part 'markdown_code_block.dart';
part 'assistant_actions.dart';
part 'failure_actions.dart';
part 'loading_dots.dart';
part 'streaming_caret.dart';
part 'status_chip.dart';

class MessageBubble extends ConsumerWidget {
  const MessageBubble({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isUser = message.role == MessageRole.user;
    final maxWidth = MediaQuery.sizeOf(context).width *
        AppBreakpoints.messageMaxFraction(isUser: isUser);
    final motion = AppMotion.of(context, AppMotion.normal);

    final messages =
        ref.watch(chatProvider).messagesFor(message.conversationId);
    final canRetry = message.status == MessageStatus.failed &&
        messages.isNotEmpty &&
        messages.last.id == message.id;

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
                            message.conversationId,
                            message.id,
                          );
                    }
                  : null,
            ),
    );
  }
}
