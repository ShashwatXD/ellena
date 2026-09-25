import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

class HoldMenuItem<T> {
  const HoldMenuItem({
    required this.value,
    required this.label,
    required this.icon,
    this.danger = false,
  });

  final T value;
  final String label;
  final IconData icon;
  final bool danger;
}

abstract final class HoldMenu {
  static Future<T?> show<T>(
    BuildContext context, {
    required Rect anchor,
    required Widget preview,
    required List<HoldMenuItem<T>> items,
    bool alignEnd = false,
    double? preferredHeight,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: AppMotion.normal,
      pageBuilder: (context, animation, secondaryAnimation) {
        return _HoldPreview<T>(
          anchor: anchor,
          preview: preview,
          items: items,
          alignEnd: alignEnd,
          preferredHeight: preferredHeight,
          animation: animation,
        );
      },
    );
  }
}

class _HoldPreview<T> extends StatelessWidget {
  const _HoldPreview({
    required this.anchor,
    required this.preview,
    required this.items,
    required this.alignEnd,
    this.preferredHeight,
    required this.animation,
  });

  final Rect anchor;
  final Widget preview;
  final List<HoldMenuItem<T>> items;
  final bool alignEnd;
  final double? preferredHeight;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.standard,
    );
    const edge = 16.0;
    const breathing = 80.0;
    final topLimit = media.padding.top + edge;
    final bottomLimit = media.size.height - media.padding.bottom - edge;
    final maxMenu = media.size.width - edge * 2;
    var menuWidth = anchor.width < 220 ? 220.0 : anchor.width;
    if (menuWidth > maxMenu) menuWidth = maxMenu;
    final menuHeight = items.length * 48.0 + 8;
    const gap = AppSpacing.sm;
    final room = (bottomLimit - topLimit - gap - menuHeight - breathing).clamp(
      48.0,
      media.size.height,
    );
    final wanted = preferredHeight ?? anchor.height;
    final previewHeight = wanted > room ? room : wanted;
    var top = anchor.top < topLimit ? topLimit : anchor.top;
    final overflow = top + previewHeight + gap + menuHeight - bottomLimit;
    if (overflow > 0) top -= overflow;
    if (top < topLimit) top = topLimit;

    var bubbleLeft = anchor.left;
    var bubbleWidth = anchor.width;
    if (bubbleLeft < edge) {
      bubbleWidth -= edge - bubbleLeft;
      bubbleLeft = edge;
    }
    if (bubbleLeft + bubbleWidth > media.size.width - edge) {
      bubbleWidth = media.size.width - edge - bubbleLeft;
    }
    final columnWidth = bubbleWidth > menuWidth ? bubbleWidth : menuWidth;
    var columnLeft = alignEnd ? anchor.right - columnWidth : bubbleLeft;
    if (columnLeft < edge) columnLeft = edge;
    if (columnLeft + columnWidth > media.size.width - edge) {
      columnLeft = media.size.width - edge - columnWidth;
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned(
              left: columnLeft,
              top: top,
              width: columnWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: alignEnd
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: room,
                    maxWidth: bubbleWidth,
                  ),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
                      child: preview,
                    ),
                  ),
                  const SizedBox(height: gap),
                  FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.06),
                        end: Offset.zero,
                      ).animate(curved),
                      child: SizedBox(
                        width: menuWidth,
                        child: _ActionCard<T>(items: items),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard<T> extends StatelessWidget {
  const _ActionCard({required this.items});

  final List<HoldMenuItem<T>> items;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      elevation: 8,
      shadowColor: colors.shadow.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(AppRadii.lg),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: colors.outline),
            _ActionRow<T>(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _ActionRow<T> extends StatelessWidget {
  const _ActionRow({required this.item});

  final HoldMenuItem<T> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final color = item.danger ? colors.error : colors.onSurface;

    return InkWell(
      onTap: () => Navigator.of(context).pop(item.value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            Icon(item.icon, size: 20, color: color),
          ],
        ),
      ),
    );
  }
}
