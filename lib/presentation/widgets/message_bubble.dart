import 'package:flutter/material.dart';
import 'package:flutter_streaming_text_markdown/flutter_streaming_text_markdown.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/message.dart';
import '../../core/models/message_status.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isUser = message.role == MessageRole.user;
    final maxWidth = MediaQuery.sizeOf(context).width * (isUser ? 0.78 : 0.92);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 6),
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
  });

  final Message message;
  final double maxWidth;
  final ThemeData theme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final streaming = message.status == MessageStatus.streaming;
    final empty = message.content.isEmpty;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (empty && streaming)
              const _StreamingCaret()
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
                const SizedBox(height: 2),
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
            if (message.status == MessageStatus.failed) ...[
              const SizedBox(height: AppSpacing.xs),
              _StatusChip(
                label: message.error ?? AppConstants.genericErrorRetry,
                color: colors.error,
                background: colors.error.withValues(alpha: 0.08),
              ),
            ],
          ],
        ),
      ),
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
