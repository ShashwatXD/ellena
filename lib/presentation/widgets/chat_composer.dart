import 'package:flutter/material.dart';

import '../theme/app_radii.dart';

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

class _ChatComposerState extends State<ChatComposer> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool get _canSend =>
      widget.enabled &&
      !widget.isStreaming &&
      _controller.text.trim().isNotEmpty;

  bool get _isHero => widget.placement == ComposerPlacement.hero;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canSend) return;
    final text = _controller.text;
    _controller.clear();
    setState(() {});
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final field = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(_isHero ? AppRadii.xl : AppRadii.lg),
        border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
        boxShadow: _isHero
            ? [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(4, _isHero ? 8 : 4, 4, _isHero ? 8 : 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled && !widget.isStreaming,
              minLines: _isHero ? 2 : 1,
              maxLines: 6,
              textInputAction: TextInputAction.newline,
              onChanged: (_) => setState(() {}),
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Add',
                    onPressed: widget.enabled && !widget.isStreaming ? () {} : null,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      foregroundColor: colors.onSurfaceVariant,
                    ),
                    icon: const Icon(Icons.add_circle_outline, size: 22),
                  ),
                  const Spacer(),
                  if (widget.isStreaming)
                    IconButton(
                      tooltip: 'Stop',
                      onPressed: widget.onStop,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        foregroundColor: colors.onSurface,
                      ),
                      icon: const Icon(Icons.stop_circle_outlined),
                    )
                  else
                    IconButton.filled(
                      tooltip: 'Send',
                      onPressed: _canSend ? _submit : null,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        backgroundColor: _canSend
                            ? colors.primary
                            : colors.outline.withValues(alpha: 0.45),
                        foregroundColor: colors.onPrimary,
                        disabledForegroundColor: colors.onSurfaceVariant,
                      ),
                      icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (_isHero) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: field,
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: field,
      ),
    );
  }
}
