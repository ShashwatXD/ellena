part of 'message_bubble.dart';

class _MarkdownCodeBlock extends StatelessWidget {
  const _MarkdownCodeBlock({
    required this.name,
    required this.code,
    required this.style,
    required this.colors,
  });

  final String name;
  final String code;
  final TextStyle style;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: colors.outline,
          width: AppSpacing.stroke,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (name.isNotEmpty) ...[
            Text(
              name,
              style: style.copyWith(
                fontSize: 11,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          SelectableText(code, style: style),
        ],
      ),
    );
  }
}
