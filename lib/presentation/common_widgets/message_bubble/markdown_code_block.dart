part of 'message_bubble.dart';

class _MarkdownCodeBlock extends StatefulWidget {
  const _MarkdownCodeBlock({required this.name, required this.code});

  final String name;
  final String code;

  @override
  State<_MarkdownCodeBlock> createState() => _MarkdownCodeBlockState();
}

class _MarkdownCodeBlockState extends State<_MarkdownCodeBlock> {
  bool _copied = false;
  Timer? _reset;

  @override
  void didUpdateWidget(covariant _MarkdownCodeBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code == widget.code) return;
    _reset?.cancel();
    _copied = false;
  }

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await ClipboardCopy.copy(context, widget.code);
    if (!mounted) return;
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final codeStyle = AppTypography.codeStyle(AppColors.codeOnSurface);
    final label = widget.name.trim().isEmpty ? 'code' : widget.name.trim();
    final code = widget.code;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.codeSurface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.codeLine, width: AppSpacing.stroke),
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
                  onPressed: code.trim().isEmpty ? null : _copy,
                  tooltip: AppConstants.copyTooltip,
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.codeMuted,
                    disabledForegroundColor: AppColors.codeMuted.withValues(
                      alpha: 0.35,
                    ),
                    padding: const EdgeInsets.all(6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: AnimatedSwitcher(
                    duration: AppMotion.fast,
                    child: Icon(
                      _copied ? Icons.check_rounded : Icons.copy_rounded,
                      key: ValueKey(_copied),
                      size: 15,
                    ),
                  ),
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
            child: SelectableText(code, style: codeStyle),
          ),
        ],
      ),
    );
  }
}
