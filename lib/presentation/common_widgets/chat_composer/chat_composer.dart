import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../theme/app_breakpoints.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../add_to_chat_sheet.dart';
import '../app_bottom_sheet.dart';
import '../connectors_sheet.dart';

part 'composer_round_button.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    this.onStop,
    this.isStreaming = false,
    this.enabled = true,
    this.hintText,
  });

  final ValueChanged<String> onSend;
  final VoidCallback? onStop;
  final bool isStreaming;
  final bool enabled;

  final String? hintText;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _fieldKey = GlobalKey();
  late final AnimationController _pulse;

  bool get _canSend =>
      widget.enabled &&
      !widget.isStreaming &&
      _controller.text.trim().isNotEmpty;

  bool get _expanded =>
      _focusNode.hasFocus || _controller.text.isNotEmpty || widget.isStreaming;

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

  void _openSheet(WidgetBuilder builder) {
    if (!widget.enabled || widget.isStreaming) return;
    HapticFeedback.selectionClick();
    _focusNode.unfocus();
    AppBottomSheet.show(context, builder: builder);
  }

  void _openAddSheet() {
    _openSheet((_) => const AddToChatSheet());
  }

  void _openConnectors() {
    _openSheet((_) => const ConnectorsSheet());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controlsEnabled = widget.enabled && !widget.isStreaming;
    final motion = AppMotion.of(context, AppMotion.normal);
    final expanded = _expanded;

    final chrome = AnimatedContainer(
      duration: motion,
      curve: AppMotion.standard,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(
          expanded ? AppRadii.xl : AppRadii.pill,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: isDark ? 0.22 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedSize(
        duration: motion,
        curve: AppMotion.standard,
        alignment: Alignment.bottomCenter,
        child: expanded
            ? _expandedBody(theme, colors, isDark, controlsEnabled)
            : _collapsedBody(theme, colors, controlsEnabled),
      ),
    );

    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      minimum: EdgeInsets.only(
        bottom: MediaQuery.viewPaddingOf(context).bottom > 0
            ? 0
            : AppSpacing.xs,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppBreakpoints.pagePadding(context),
          AppSpacing.xs,
          AppBreakpoints.pagePadding(context),
          AppSpacing.sm,
        ),
        child: chrome,
      ),
    );
  }

  Widget _collapsedBody(
    ThemeData theme,
    ColorScheme colors,
    bool controlsEnabled,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          _ComposerGlyph(
            icon: Icons.add,
            tooltip: AppConstants.addToChatTitle,
            onPressed: controlsEnabled ? _openAddSheet : null,
          ),
          Expanded(
            child: _input(
              theme: theme,
              colors: colors,
              enabled: controlsEnabled,
              hint: _hint(idle: true),
              maxLines: 1,
              padding: EdgeInsets.zero,
            ),
          ),
          const _ComposerGlyph(icon: Icons.mic_none_rounded),
          const SizedBox(width: AppSpacing.xxs),
        ],
      ),
    );
  }

  Widget _expandedBody(
    ThemeData theme,
    ColorScheme colors,
    bool isDark,
    bool controlsEnabled,
  ) {
    final motion = AppMotion.of(context, AppMotion.normal);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _input(
          theme: theme,
          colors: colors,
          enabled: controlsEnabled,
          hint: _hint(idle: false),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            14,
            AppSpacing.md,
            AppSpacing.sm,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxs,
            0,
            AppSpacing.xxs,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              _ComposerGlyph(
                icon: Icons.add,
                tooltip: AppConstants.addToChatTitle,
                onPressed: controlsEnabled ? _openAddSheet : null,
              ),
              _ComposerGlyph(
                icon: Icons.electrical_services_outlined,
                tooltip: AppConstants.settingsConnectors,
                onPressed: controlsEnabled ? _openConnectors : null,
              ),
              const Spacer(),
              const _ComposerGlyph(icon: Icons.mic_none_rounded),
              AnimatedSwitcher(
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
                        foreground: _canSend
                            ? (isDark ? colors.surface : colors.onPrimary)
                            : colors.onSurfaceVariant,
                        filled: true,
                        fillColor: _canSend
                            ? (isDark ? colors.onSurface : colors.primary)
                            : colors.surfaceContainerHighest,
                        dimWhenDisabled: false,
                        emphasize: _canSend,
                      ),
              ),
              const SizedBox(width: AppSpacing.xxs),
            ],
          ),
        ),
      ],
    );
  }

  String _hint({required bool idle}) {
    final override = widget.hintText;
    if (override != null) return override;
    return idle
        ? AppConstants.composerIdleHint
        : AppConstants.composerActiveHint;
  }

  Widget _input({
    required ThemeData theme,
    required ColorScheme colors,
    required bool enabled,
    required String hint,
    required EdgeInsets padding,
    int minLines = 1,
    int maxLines = 6,
  }) {
    return TextField(
      key: _fieldKey,
      controller: _controller,
      focusNode: _focusNode,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      textInputAction: TextInputAction.newline,
      onChanged: (_) => setState(() {}),
      style: theme.textTheme.bodyLarge,
      cursorColor: colors.onSurface,
      decoration: InputDecoration(
        isCollapsed: true,
        hintText: hint,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: colors.onSurfaceVariant.withValues(alpha: 0.9),
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        filled: false,
        fillColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        contentPadding: padding,
      ),
    );
  }
}
