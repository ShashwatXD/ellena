import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import 'model_selector.dart';

enum ComposerPlacement { hero, docked }

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    this.onStop,
    this.isStreaming = false,
    this.enabled = true,
    this.hintText = 'Assign a task or ask anything',
    this.placement = ComposerPlacement.docked,
  });

  final ValueChanged<String> onSend;
  final VoidCallback? onStop;
  final bool isStreaming;
  final bool enabled;
  final String hintText;
  final ComposerPlacement placement;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late final AnimationController _pulse;

  bool get _canSend =>
      widget.enabled &&
      !widget.isStreaming &&
      _controller.text.trim().isNotEmpty;

  bool get _isHero => widget.placement == ComposerPlacement.hero;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(covariant ChatComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStreaming && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isStreaming && _pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canSend) return;
    HapticFeedback.lightImpact();
    final text = _controller.text;
    _controller.clear();
    setState(() {});
    widget.onSend(text);
  }

  void _stop() {
    HapticFeedback.mediumImpact();
    widget.onStop?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final focused = _focusNode.hasFocus;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final controlsEnabled = widget.enabled && !widget.isStreaming;

    final field = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(_isHero ? AppRadii.xl : AppRadii.lg),
        border: Border.all(
          color: focused
              ? colors.onSurface.withValues(alpha: 0.35)
              : colors.outline.withValues(alpha: 0.85),
          width: focused ? 1.25 : AppSpacing.stroke,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: _isHero ? 0.08 : 0.04),
            blurRadius: _isHero ? 28 : 16,
            offset: Offset(0, _isHero ? 10 : 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: controlsEnabled,
                    minLines: _isHero ? 2 : 1,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                    onChanged: (_) => setState(() {}),
                    style: theme.textTheme.bodyLarge,
                    cursorColor: colors.onSurface,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.85),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        _isHero ? 16 : 14,
                        AppSpacing.sm,
                        6,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.sm,
                      AppSpacing.sm,
                    ),
                    child: ModelSelector(enabled: controlsEnabled),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: widget.isStreaming
                    ? FadeTransition(
                        key: const ValueKey('stop'),
                        opacity: Tween<double>(begin: 0.55, end: 1).animate(
                          CurvedAnimation(
                            parent: _pulse,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: _RoundIconButton(
                          tooltip: 'Stop',
                          icon: Icons.stop_rounded,
                          onPressed: widget.onStop == null ? null : _stop,
                          foreground: colors.onSurface,
                          filled: true,
                          fillColor: colors.surfaceContainerHighest,
                        ),
                      )
                    : _RoundIconButton(
                        key: const ValueKey('send'),
                        tooltip: 'Send',
                        icon: Icons.arrow_upward_rounded,
                        onPressed: _canSend ? _submit : null,
                        foreground:
                            _canSend ? colors.onPrimary : colors.onSurface,
                        filled: true,
                        fillColor: _canSend ? colors.primary : colors.outline,
                        dimWhenDisabled: false,
                      ),
              ),
            ),
          ],
        ),
      ),
    );

    if (_isHero) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        child: field,
      );
    }

    return AnimatedPadding(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset > 0 ? 0 : 0),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: field,
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.foreground,
    this.filled = false,
    this.fillColor,
    this.dimWhenDisabled = true,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color foreground;
  final bool filled;
  final Color? fillColor;
  final bool dimWhenDisabled;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final iconColor = !enabled && dimWhenDisabled
        ? foreground.withValues(alpha: 0.4)
        : foreground;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled
            ? (fillColor ?? Theme.of(context).colorScheme.primary)
            : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: AppSpacing.tap,
            height: AppSpacing.tap,
            child: Icon(
              icon,
              size: AppSpacing.icon,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
