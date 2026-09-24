part of 'chat_composer.dart';

class _RoundIconButton extends StatefulWidget {
  const _RoundIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.foreground,
    this.filled = false,
    this.fillColor,
    this.dimWhenDisabled = true,
    this.emphasize = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color foreground;
  final bool filled;
  final Color? fillColor;
  final bool dimWhenDisabled;
  final bool emphasize;

  @override
  State<_RoundIconButton> createState() => _RoundIconButtonState();
}

class _RoundIconButtonState extends State<_RoundIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final iconColor = !enabled && widget.dimWhenDisabled
        ? widget.foreground.withValues(alpha: 0.4)
        : widget.foreground;
    final motion = AppMotion.of(context, AppMotion.fast);

    return Tooltip(
      message: widget.tooltip,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : (widget.emphasize ? 1.0 : 1.0),
        duration: motion,
        curve: AppMotion.standard,
        child: Material(
          color: widget.filled
              ? (widget.fillColor ?? Theme.of(context).colorScheme.primary)
              : Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onPressed,
            onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            child: SizedBox(
              width: AppSpacing.tap,
              height: AppSpacing.tap,
              child: Icon(
                widget.icon,
                size: AppSpacing.icon,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
