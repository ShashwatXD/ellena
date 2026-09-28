part of 'message_bubble.dart';

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({
    required this.message,
    required this.maxWidth,
    required this.theme,
    required this.colors,
    this.onRetry,
    this.onLongPress,
  });

  final Message message;
  final double maxWidth;
  final ThemeData theme;
  final ColorScheme colors;
  final VoidCallback? onRetry;
  final void Function(BuildContext bubbleContext)? onLongPress;

  @override
  Widget build(BuildContext context) {
    final streaming = message.status == MessageStatus.streaming;
    final failed = message.status == MessageStatus.failed;
    final stopped = message.status == MessageStatus.stopped;
    final empty = message.content.isEmpty;
    final stoppedBeforeReply =
        stopped && (empty || message.content == AppConstants.stoppedLabel);
    final shown = visibleMarkdown(message.content);
    final inlineCodeStyle = AppTypography.codeStyle(colors.onSurface);

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MessageBlock(
              user: false,
              maxWidth: maxWidth,
              onLongPress: onLongPress,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (empty && streaming)
                    const _LoadingDots()
                  else if (stoppedBeforeReply)
                    const _ErrorLine(label: AppConstants.stoppedLabel)
                  else if (empty && failed)
                    _ErrorLine(
                      label: message.error ?? AppConstants.genericError,
                    )
                  else ...[
                    _ReplyWidth(
                      text: shown,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                      maxWidth: maxWidth,
                      child: StreamingTextMarkdown(
                        key: ValueKey(
                          '${message.id}-${message.status.name}-${theme.brightness.name}',
                        ),
                        text: shown,
                        markdownEnabled: true,
                        animationsEnabled: false,
                        autoScroll: false,
                        padding: EdgeInsets.zero,
                        styleSheet: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                        onLinkTap: (url, title) {
                          OpenLink.open(url);
                        },
                        codeBuilder: (context, name, code, closed) =>
                            _MarkdownCodeBlock(name: name, code: code),
                        highlightBuilder: (context, text, style) => Text(
                          text,
                          style: inlineCodeStyle.copyWith(
                            backgroundColor: colors.surface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        imageBuilder: (context, url) =>
                            _MarkdownImage(url: url),
                      ),
                    ),
                    if (streaming) ...[
                      const SizedBox(height: 4),
                      const _StreamingCaret(),
                    ],
                  ],
                ],
              ),
            ),
            if (stopped && !stoppedBeforeReply) ...[
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
          ],
        ),
      ),
    );
  }
}

class _ReplyWidth extends StatelessWidget {
  const _ReplyWidth({
    required this.text,
    required this.style,
    required this.maxWidth,
    required this.child,
  });

  final String text;
  final TextStyle? style;
  final double maxWidth;
  final Widget child;

  static const _horizontalPad = 28.0;

  @override
  Widget build(BuildContext context) {
    final inner = (maxWidth - _horizontalPad).clamp(0.0, maxWidth);
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
    )..layout(maxWidth: inner);

    return SizedBox(width: painter.size.width.clamp(0.0, inner), child: child);
  }
}

class _MarkdownImage extends StatelessWidget {
  const _MarkdownImage({required this.url, this.width, this.height});

  final String url;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fromUrl = _sizeInUrl(url);
    final boxWidth = width ?? fromUrl.$1 ?? 240;
    final boxHeight = height ?? fromUrl.$2 ?? width ?? 160;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Image.network(
        url,
        width: boxWidth,
        height: boxHeight,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: boxWidth,
            height: boxHeight,
            child: ColoredBox(
              color: colors.surfaceContainerHighest,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: boxWidth,
            height: boxHeight,
            child: ColoredBox(
              color: colors.surfaceContainerHighest,
              child: Icon(
                Icons.broken_image_outlined,
                color: colors.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}

(double?, double?) _sizeInUrl(String url) {
  final segments = Uri.tryParse(url)?.pathSegments;
  if (segments == null || segments.length < 2) return (null, null);
  final width = double.tryParse(segments[segments.length - 2]);
  final height = double.tryParse(segments.last.split('.').first);
  if (width == null || height == null) return (null, null);
  if (width < 16 || height < 16 || width > 2000 || height > 2000) {
    return (null, null);
  }
  return (width, height);
}
