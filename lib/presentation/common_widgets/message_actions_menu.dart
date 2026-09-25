import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../theme/app_motion.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

enum MessageAction { ask, share, copy, selectText, report }

abstract final class MessageActionsMenu {
  static const assistant = <MessageAction>[
    MessageAction.ask,
    MessageAction.share,
    MessageAction.copy,
    MessageAction.selectText,
    MessageAction.report,
  ];

  static const user = <MessageAction>[
    MessageAction.ask,
    MessageAction.copy,
    MessageAction.selectText,
  ];

  static Future<MessageAction?> show(
    BuildContext context, {
    required Rect anchor,
    required String text,
    required bool isUser,
  }) {
    return showGeneralDialog<MessageAction>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: AppMotion.normal,
      pageBuilder: (context, animation, secondaryAnimation) {
        return _HoldPreview(
          anchor: anchor,
          text: text,
          isUser: isUser,
          animation: animation,
        );
      },
    );
  }
}

class _HoldPreview extends StatelessWidget {
  const _HoldPreview({
    required this.anchor,
    required this.text,
    required this.isUser,
    required this.animation,
  });

  final Rect anchor;
  final String text;
  final bool isUser;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.standard,
    );
    final actions = isUser
        ? MessageActionsMenu.user
        : MessageActionsMenu.assistant;
    const edge = 16.0;
    final topLimit = media.padding.top + edge;
    final bottomLimit = media.size.height - media.padding.bottom - edge;
    final maxMenu = media.size.width - edge * 2;
    var menuWidth = anchor.width < 220 ? 220.0 : anchor.width;
    if (menuWidth > maxMenu) menuWidth = maxMenu;
    var left = isUser ? anchor.right - menuWidth : anchor.left;
    if (left < edge) left = edge;
    if (left + menuWidth > media.size.width - edge) {
      left = media.size.width - edge - menuWidth;
    }
    final menuHeight = actions.length * 48.0 + 8;
    final gap = AppSpacing.sm;
    final room = bottomLimit - topLimit - gap - menuHeight;
    final bubbleHeight = room <= 0
        ? 0.0
        : (anchor.height < room ? anchor.height : room);
    var top = anchor.top;
    if (top < topLimit) top = topLimit;
    if (top + bubbleHeight + gap + menuHeight > bottomLimit) {
      top = bottomLimit - bubbleHeight - gap - menuHeight;
    }
    if (top < topLimit) top = topLimit;
    var bubbleLeft = anchor.left;
    var bubbleWidth = anchor.width;
    if (bubbleLeft < edge) bubbleLeft = edge;
    if (bubbleLeft + bubbleWidth > media.size.width - edge) {
      bubbleWidth = media.size.width - edge - bubbleLeft;
    }

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned(
            left: bubbleLeft,
            top: top,
            width: bubbleWidth,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: bubbleHeight),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: _LiftedMessage(text: text, isUser: isUser),
                ),
              ),
            ),
          ),
          Positioned(
            left: left,
            top: top + bubbleHeight + gap,
            width: menuWidth,
            child: FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.06),
                  end: Offset.zero,
                ).animate(curved),
                child: _ActionCard(actions: actions),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiftedMessage extends StatelessWidget {
  const _LiftedMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;

  static const _corner = Radius.circular(AppRadii.lg);
  static const _point = Radius.circular(5);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.only(
          topLeft: _corner,
          topRight: _corner,
          bottomLeft: isUser ? _corner : _point,
          bottomRight: isUser ? _point : _corner,
        ),
        border: isUser
            ? Border.all(color: colors.outline, width: AppSpacing.stroke)
            : null,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Text(
          text,
          overflow: TextOverflow.fade,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.actions});

  final List<MessageAction> actions;

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
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) Divider(height: 1, color: colors.outline),
            _ActionRow(action: actions[i]),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.action});

  final MessageAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final (label, icon) = switch (action) {
      MessageAction.ask => (AppConstants.askEllenaLabel, Icons.format_quote),
      MessageAction.share => (AppConstants.shareLabel, Icons.ios_share),
      MessageAction.copy => (AppConstants.copyLabel, Icons.copy_outlined),
      MessageAction.selectText => (
        AppConstants.selectTextLabel,
        Icons.text_snippet_outlined,
      ),
      MessageAction.report => (
        AppConstants.reportLabel,
        Icons.warning_amber_outlined,
      ),
    };

    return InkWell(
      onTap: () => Navigator.of(context).pop(action),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(icon, size: 20, color: colors.onSurface),
          ],
        ),
      ),
    );
  }
}
