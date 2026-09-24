part of 'message_bubble.dart';

class _FailureActions extends StatefulWidget {
  const _FailureActions({
    required this.onRetry,
    required this.summary,
    this.detail,
    this.showSummary = false,
  });

  final String summary;
  final String? detail;
  final bool showSummary;
  final VoidCallback? onRetry;

  @override
  State<_FailureActions> createState() => _FailureActionsState();
}

class _FailureActionsState extends State<_FailureActions> {
  bool _pressed = false;
  bool _expanded = false;

  bool get _hasDetail {
    final detail = widget.detail?.trim();
    if (detail == null || detail.isEmpty) return false;
    return detail != widget.summary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final motion = AppMotion.of(context, AppMotion.fast);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showSummary)
          Padding(
            padding: EdgeInsets.only(bottom: _hasDetail || widget.onRetry != null ? 6 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: colors.error.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.summary,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.error.withValues(alpha: 0.95),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (_hasDetail) ...[
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _expanded
                        ? AppConstants.showLessLabel
                        : AppConstants.knowMoreLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 4),
              child: Text(
                widget.detail!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: motion,
            sizeCurve: AppMotion.standard,
          ),
        ],
        if (widget.onRetry != null) ...[
          if (_hasDetail || widget.showSummary)
            const SizedBox(height: AppSpacing.xs),
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
      ],
    );
  }
}
