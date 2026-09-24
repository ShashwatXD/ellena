import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../theme/app_breakpoints.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../model_selector.dart';

part 'composer_round_button.dart';

enum ComposerPlacement { hero, docked }

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    this.onStop,
    this.isStreaming = false,
    this.enabled = true,
    this.hintText = AppConstants.composerHint,
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
    final controlsEnabled = widget.enabled && !widget.isStreaming;
    final motion = AppMotion.of(context, AppMotion.normal);

    final field = AnimatedContainer(
      duration: motion,
      curve: AppMotion.standard,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(_isHero ? AppRadii.xl : AppRadii.lg),
        border: Border.all(
          color: focused
              ? colors.onSurface.withValues(alpha: 0.38)
              : colors.outline.withValues(alpha: 0.9),
          width: focused ? 1.35 : AppSpacing.stroke,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(
              alpha: focused
                  ? (_isHero ? 0.12 : 0.08)
                  : (_isHero ? 0.07 : 0.04),
            ),
            blurRadius: focused
                ? (_isHero ? 32 : 22)
                : (_isHero ? 26 : 14),
            offset: Offset(0, _isHero ? 10 : 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: AnimatedSize(
                duration: motion,
                curve: AppMotion.standard,
                alignment: Alignment.topCenter,
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
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: AnimatedSwitcher(
                duration: motion,
                switchInCurve: AppMotion.enter,
                switchOutCurve: AppMotion.exit,
                transitionBuilder: (child, animation) {
                  return AppMotion.scaleFadeTransition(
                    animation: animation,
                    child: child,
                  );
                },
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
                          tooltip: AppConstants.stopTooltip,
                          icon: Icons.stop_rounded,
                          onPressed: widget.onStop == null ? null : _stop,
                          foreground: colors.onSurface,
                          filled: true,
                          fillColor: colors.surfaceContainerHighest,
                        ),
                      )
                    : _RoundIconButton(
                        key: const ValueKey('send'),
                        tooltip: AppConstants.sendTooltip,
                        icon: Icons.arrow_upward_rounded,
                        onPressed: _canSend ? _submit : null,
                        foreground:
                            _canSend ? colors.onPrimary : colors.onSurface,
                        filled: true,
                        fillColor: _canSend ? colors.primary : colors.outline,
                        dimWhenDisabled: false,
                        emphasize: _canSend,
                      ),
              ),
            ),
          ],
        ),
      ),
    );

    if (_isHero) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppBreakpoints.pagePadding(context),
        ),
        child: field,
      );
    }

    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      minimum: EdgeInsets.only(
        bottom: MediaQuery.viewPaddingOf(context).bottom > 0 ? 0 : AppSpacing.xs,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppBreakpoints.pagePadding(context),
          AppSpacing.xs,
          AppBreakpoints.pagePadding(context),
          AppSpacing.sm,
        ),
        child: field,
      ),
    );
  }
}
