part of 'message_bubble.dart';

class _MarkdownCodeBlock extends StatelessWidget {
  const _MarkdownCodeBlock({
    required this.name,
    required this.code,
  });

  final String name;
  final String code;

  @override
  Widget build(BuildContext context) {
    final codeStyle = AppTypography.codeStyle(AppColors.codeOnSurface);
    final label = name.trim().isEmpty ? 'code' : name.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.codeSurface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: AppColors.codeLine,
          width: AppSpacing.stroke,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm + 2,
              AppSpacing.xs + 2,
              AppSpacing.xs,
              AppSpacing.xs + 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: codeStyle.copyWith(
                      fontSize: 11,
                      color: AppColors.codeMuted,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: code.trim().isEmpty
                      ? null
                      : () => ClipboardCopy.copy(context, code),
                  tooltip: AppConstants.copyTooltip,
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.codeMuted,
                    disabledForegroundColor:
                        AppColors.codeMuted.withValues(alpha: 0.35),
                    padding: const EdgeInsets.all(6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 15),
                ),
              ],
            ),
          ),
          Divider(
            height: AppSpacing.stroke,
            thickness: AppSpacing.stroke,
            color: AppColors.codeLine,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm + 2,
              AppSpacing.sm,
              AppSpacing.sm + 2,
              AppSpacing.sm + 2,
            ),
            child: SelectableText(
              code,
              style: codeStyle,
            ),
          ),
        ],
      ),
    );
  }
}
