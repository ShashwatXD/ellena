import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import 'hold_menu.dart';

enum MessageAction { ask, share, copy, selectText, report }

abstract final class MessageActionsMenu {
  static Future<MessageAction?> show(
    BuildContext context, {
    required Rect anchor,
    required String text,
    required bool isUser,
    Widget? rendered,
  }) {
    final actions = isUser ? _user : _assistant;
    return HoldMenu.show<MessageAction>(
      context,
      anchor: anchor,
      alignEnd: isUser,
      preview: _LiftedMessage(text: text, isUser: isUser, rendered: rendered),
      items: [
        for (final action in actions)
          HoldMenuItem(value: action, label: action.label, icon: action.icon),
      ],
    );
  }
}

const _assistant = <MessageAction>[
  MessageAction.ask,
  MessageAction.share,
  MessageAction.copy,
  MessageAction.selectText,
  MessageAction.report,
];

const _user = <MessageAction>[
  MessageAction.ask,
  MessageAction.copy,
  MessageAction.selectText,
];

extension on MessageAction {
  String get label => switch (this) {
    MessageAction.ask => AppConstants.askEllenaLabel,
    MessageAction.share => AppConstants.shareLabel,
    MessageAction.copy => AppConstants.copyLabel,
    MessageAction.selectText => AppConstants.selectTextLabel,
    MessageAction.report => AppConstants.reportLabel,
  };

  IconData get icon => switch (this) {
    MessageAction.ask => Icons.format_quote,
    MessageAction.share => Icons.ios_share,
    MessageAction.copy => Icons.copy_outlined,
    MessageAction.selectText => Icons.text_snippet_outlined,
    MessageAction.report => Icons.warning_amber_outlined,
  };
}

class _LiftedMessage extends StatelessWidget {
  const _LiftedMessage({
    required this.text,
    required this.isUser,
    this.rendered,
  });

  final String text;
  final bool isUser;
  final Widget? rendered;

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
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: _corner,
          topRight: _corner,
          bottomLeft: isUser ? _corner : _point,
          bottomRight: isUser ? _point : _corner,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: rendered == null
              ? Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.45),
                )
              : ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [rendered!],
                ),
        ),
      ),
    );
  }
}
