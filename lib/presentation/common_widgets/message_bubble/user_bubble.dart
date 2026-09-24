part of 'message_bubble.dart';

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
