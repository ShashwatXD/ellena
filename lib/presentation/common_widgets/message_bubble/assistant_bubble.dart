part of 'message_bubble.dart';

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
    final complete = message.status == MessageStatus.complete;
    final stopped = message.status == MessageStatus.stopped;
    final empty = message.content.isEmpty;
    final inlineCodeStyle = AppTypography.codeStyle(colors.onSurface);

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
                key: ValueKey(
                  '${message.id}-${message.status.name}-${theme.brightness.name}',
                ),
                text: message.content,
                markdownEnabled: true,
                animationsEnabled: false,
                autoScroll: false,
                styleSheet: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                padding: EdgeInsets.zero,
                codeBuilder: (context, name, code, closed) =>
                    _MarkdownCodeBlock(name: name, code: code),
                highlightBuilder: (context, text, style) => Text(
                  text,
                  style: inlineCodeStyle.copyWith(
                    backgroundColor:
                        colors.surfaceContainerHighest.withValues(alpha: 0.7),
                  ),
                ),
              ),
              if (streaming) ...[
                const SizedBox(height: 4),
                const _StreamingCaret(),
              ],
            ],
            if (stopped) ...[
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
                summary: message.error ?? AppConstants.genericError,
                detail: message.errorDetail,
                showSummary: !empty,
                onRetry: onRetry,
              ),
            ],
            if (!empty && (complete || stopped)) ...[
              const SizedBox(height: AppSpacing.sm),
              _AssistantActions(
                content: message.content,
                showSuccess: complete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
