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
import '../../utils/clipboard_copy.dart';
import '../../utils/open_link.dart';
import '../message_actions_menu.dart';
import '../select_text_sheet.dart';

part 'user_bubble.dart';
part 'assistant_bubble.dart';
part 'markdown_code_block.dart';
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
    final maxWidth =
        MediaQuery.sizeOf(context).width *
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
              onLongPress: (bubble) => _openActions(bubble, ref, message, true),
            )
          : _AssistantBubble(
              message: message,
              maxWidth: maxWidth,
              theme: theme,
              colors: colors,
              onLongPress: (bubble) =>
                  _openActions(bubble, ref, message, false),
              onRetry: canRetry
                  ? () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(chatProvider.notifier)
                          .retryMessage(conversationId, messageId);
                    }
                  : null,
            ),
    );
  }
}

Future<void> _openActions(
  BuildContext context,
  WidgetRef ref,
  Message message,
  bool isUser,
) async {
  final text = message.content.trim();
  if (text.isEmpty) return;
  HapticFeedback.mediumImpact();
  final box = context.findRenderObject()! as RenderBox;
  final anchor = box.localToGlobal(Offset.zero) & box.size;
  final action = await MessageActionsMenu.show(
    context,
    anchor: anchor,
    text: text,
    isUser: isUser,
  );
  if (!context.mounted || action == null) return;
  switch (action) {
    case MessageAction.ask:
      ref.read(composerQuoteProvider.notifier).set(text);
    case MessageAction.copy:
      await ClipboardCopy.copy(context, text, notify: false);
    case MessageAction.selectText:
      await SelectTextSheet.show(context, text);
    case MessageAction.share:
    case MessageAction.report:
      break;
  }
}

class _MessageBlock extends StatelessWidget {
  const _MessageBlock({
    required this.user,
    required this.maxWidth,
    required this.child,
    this.onLongPress,
  });

  final bool user;
  final double maxWidth;
  final Widget child;
  final void Function(BuildContext bubbleContext)? onLongPress;

  static const _corner = Radius.circular(AppRadii.lg);
  static const _point = Radius.circular(5);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      widthFactor: 1,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Builder(
          builder: (bubbleContext) {
            return GestureDetector(
              onLongPress: onLongPress == null
                  ? null
                  : () => onLongPress!(bubbleContext),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: user ? colors.surface : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: _corner,
                    topRight: _corner,
                    bottomLeft: user ? _corner : _point,
                    bottomRight: user ? _point : _corner,
                  ),
                  border: user
                      ? Border.all(
                          color: colors.outline,
                          width: AppSpacing.stroke,
                        )
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
