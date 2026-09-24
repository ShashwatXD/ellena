import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_streaming_text_markdown/flutter_streaming_text_markdown.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/message.dart';
import '../../core/models/message_status.dart';
import '../providers/providers.dart';
import '../theme/app_breakpoints.dart';
import '../theme/app_motion.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

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

class _UserBubble extends StatelessWidget {
  const _UserBubble({
    required this.message,
    required this.maxWidth,
    required this.theme,
    required this.colors,
  });

  final Message message;
  final double maxWidth;
  final ThemeData theme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: colors.outline,
              width: AppSpacing.stroke,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: SelectableText(
              message.content,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({
    required this.message,
    required this.maxWidth,
    required this.theme,
    required this.colors,
    this.onRetry,
  });

  final Message message;
  final double maxWidth;
  final ThemeData theme;
  final ColorScheme colors;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final streaming = message.status == MessageStatus.streaming;
    final failed = message.status == MessageStatus.failed;
    final empty = message.content.isEmpty;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (empty && streaming)
              const _LoadingDots()
            else if (empty && failed)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 18,
                      color: colors.error.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message.error ?? AppConstants.genericError,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              )
            else ...[
              StreamingTextMarkdown(
                key: ValueKey('${message.id}-${message.status.name}'),
                text: message.content,
                markdownEnabled: true,
                animationsEnabled: false,
                autoScroll: false,
                styleSheet: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                padding: EdgeInsets.zero,
              ),
              if (streaming) ...[
                const SizedBox(height: 4),
                const _StreamingCaret(),
              ],
            ],
            if (message.status == MessageStatus.stopped) ...[
              const SizedBox(height: AppSpacing.xs),
              _StatusChip(
                label: AppConstants.interruptedLabel,
                color: colors.onSurfaceVariant,
                background: colors.surfaceContainerHighest,
              ),
            ],
            if (failed) ...[
              const SizedBox(height: AppSpacing.sm),
              _FailureActions(
                showDetail: !empty,
                detail: message.error ?? AppConstants.genericError,
                onRetry: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FailureActions extends StatefulWidget {
  const _FailureActions({
    required this.onRetry,
    required this.detail,
    this.showDetail = false,
  });

  final String detail;
  final bool showDetail;
  final VoidCallback? onRetry;

  @override
  State<_FailureActions> createState() => _FailureActionsState();
}

class _FailureActionsState extends State<_FailureActions> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final motion = AppMotion.of(context, AppMotion.fast);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showDetail)
          Padding(
            padding: EdgeInsets.only(
              bottom: widget.onRetry != null ? AppSpacing.xs : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: colors.error.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.detail,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.error.withValues(alpha: 0.95),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (widget.onRetry != null)
          AnimatedScale(
            scale: _pressed ? 0.96 : 1,
            duration: motion,
            curve: AppMotion.standard,
            child: Material(
              color: colors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                side: BorderSide(
                  color: colors.outline,
                  width: AppSpacing.stroke,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                onTapDown: (_) => setState(() => _pressed = true),
                onTapCancel: () => setState(() => _pressed = false),
                onTapUp: (_) => setState(() => _pressed = false),
                onTap: widget.onRetry,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: colors.onSurface.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppConstants.retryLabel,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    final reduce = MediaQuery.disableAnimationsOf(context);

    if (reduce) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (_) {
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 5, top: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          );
        }),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final t = (_controller.value + index * 0.18) % 1.0;
            final bounce = (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
            return Transform.translate(
              offset: Offset(0, -3.5 * bounce),
              child: Opacity(
                opacity: 0.35 + 0.65 * bounce,
                child: Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 5, top: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _StreamingCaret extends StatefulWidget {
  const _StreamingCaret();

  @override
  State<_StreamingCaret> createState() => _StreamingCaretState();
}

class _StreamingCaretState extends State<_StreamingCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    if (MediaQuery.disableAnimationsOf(context)) {
      return Container(
        width: 7,
        height: 15,
        margin: const EdgeInsets.only(top: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    return FadeTransition(
      opacity: Tween<double>(begin: 0.2, end: 1).animate(_controller),
      child: Container(
        width: 7,
        height: 15,
        margin: const EdgeInsets.only(top: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}
