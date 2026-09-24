part of 'message_bubble.dart';

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
