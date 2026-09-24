import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/conversation.dart';
import '../navigation/app_routes.dart';
import '../providers/providers.dart';
import '../theme/app_motion.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

class ChatDrawer extends ConsumerWidget {
  const ChatDrawer({super.key});

  void _newChat(BuildContext context, WidgetRef ref) {
    HapticFeedback.selectionClick();
    ref.read(chatProvider.notifier).startNewChat();
    Navigator.of(context).pop();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final chat = ref.watch(chatProvider);
    final conversations = chat.conversations;
    final activeId = chat.activeConversationId;
    final pinned = conversations.where((c) => c.isPinned).toList();
    final recent = conversations.where((c) => !c.isPinned).toList();

    return SafeArea(
      left: false,
      right: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 8),
            child: Text(
              AppConstants.appName.toLowerCase(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.35,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: _NewChatButton(onPressed: () => _newChat(context, ref)),
          ),
          Divider(
            height: 1,
            thickness: AppSpacing.stroke,
            color: colors.outline,
          ),
          Expanded(
            child: conversations.isEmpty
                ? Center(
                    child: Text(
                      AppConstants.noChatsYet,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    children: [
                      if (pinned.isNotEmpty) ...[
                        const _SectionLabel(label: AppConstants.pinnedSection),
                        ...pinned.map(
                          (c) => _ConversationTile(
                            conversation: c,
                            selected: c.id == activeId,
                          ),
                        ),
                      ],
                      if (recent.isNotEmpty) ...[
                        const _SectionLabel(label: AppConstants.recentSection),
                        ...recent.map(
                          (c) => _ConversationTile(
                            conversation: c,
                            selected: c.id == activeId,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _NewChatButton extends StatefulWidget {
  const _NewChatButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_NewChatButton> createState() => _NewChatButtonState();
}

class _NewChatButtonState extends State<_NewChatButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final motion = AppMotion.of(context, AppMotion.fast);

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: motion,
      curve: AppMotion.standard,
      child: Material(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(
            color: colors.outline,
            width: AppSpacing.stroke,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.edit_square,
                  size: 18,
                  color: colors.onSurface.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 10),
                Text(
                  AppConstants.newChatLabel,
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
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.6,
            ),
      ),
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  const _ConversationTile({
    required this.conversation,
    required this.selected,
  });

  final Conversation conversation;
  final bool selected;

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final next = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _RenameChatDialog(
        initialTitle: conversation.title,
      ),
    );
    if (next == null || !context.mounted) return;
    ref.read(chatProvider.notifier).renameConversation(conversation.id, next);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colors = theme.colorScheme;
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          title: Text(
            AppConstants.deleteChatTitle,
            style: theme.textTheme.titleLarge,
          ),
          content: Text(
            AppConstants.deleteChatBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppConstants.deleteChatCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: colors.error),
              child: const Text(AppConstants.deleteChatConfirm),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(chatProvider.notifier).deleteConversation(conversation.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: selected
            ? colors.onSurface.withValues(alpha: 0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(chatProvider.notifier).openConversation(conversation.id);
            Navigator.of(context).pop();
            context.go(AppRoutes.home);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
            child: Row(
              children: [
                if (conversation.isPinned) ...[
                  Icon(
                    Icons.push_pin_rounded,
                    size: 14,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      conversation.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<_ChatAction>(
                  tooltip: AppConstants.chatActionsTooltip,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    size: 20,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.85),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  onSelected: (action) async {
                    HapticFeedback.selectionClick();
                    switch (action) {
                      case _ChatAction.pin:
                        ref
                            .read(chatProvider.notifier)
                            .togglePin(conversation.id);
                      case _ChatAction.rename:
                        await _rename(context, ref);
                      case _ChatAction.delete:
                        await _delete(context, ref);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _ChatAction.pin,
                      child: Text(
                        conversation.isPinned
                            ? AppConstants.unpinChatLabel
                            : AppConstants.pinChatLabel,
                      ),
                    ),
                    const PopupMenuItem(
                      value: _ChatAction.rename,
                      child: Text(AppConstants.renameChatLabel),
                    ),
                    PopupMenuItem(
                      value: _ChatAction.delete,
                      child: Text(
                        AppConstants.deleteChatLabel,
                        style: TextStyle(color: colors.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _ChatAction { pin, rename, delete }

class _RenameChatDialog extends StatefulWidget {
  const _RenameChatDialog({required this.initialTitle});

  final String initialTitle;

  @override
  State<_RenameChatDialog> createState() => _RenameChatDialogState();
}

class _RenameChatDialogState extends State<_RenameChatDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      title: Text(
        AppConstants.renameChatTitle,
        style: theme.textTheme.titleLarge,
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: AppConstants.renameChatHint,
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppConstants.renameChatCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text(AppConstants.renameChatSave),
        ),
      ],
    );
  }
}
