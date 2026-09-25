import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/conversation.dart';
import '../../../common_widgets/hold_menu.dart';
import '../../../providers/providers.dart';
import '../../../theme/app_motion.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_spacing.dart';

class TasksPane extends ConsumerWidget {
  const TasksPane({super.key});

  void _newChat(WidgetRef ref) {
    HapticFeedback.selectionClick();
    ref.read(chatProvider.notifier).startNewChat();
    ref.read(workspaceTabProvider.notifier).select(WorkspaceTab.agent);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final chat = ref.watch(chatProvider);
    final conversations = chat.conversations;
    final activeId = chat.activeConversationId;
    final query = ref.watch(taskSearchProvider).query;
    final visible = [
      for (final conversation in conversations)
        if (_matches(ref, conversation, query)) conversation,
    ];
    final pinned = visible.where((c) => c.isPinned).toList();
    final recent = visible.where((c) => !c.isPinned).toList();
    final searching = query.trim().isNotEmpty;
    final noHistory = conversations.isEmpty;
    final showFab = !noHistory;

    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(chatProvider.notifier).reloadHistory(),
                  child: visible.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.45,
                              child: Center(
                                child: noHistory && !searching
                                    ? _StartNewChat(
                                        large: true,
                                        onPressed: () => _newChat(ref),
                                      )
                                    : Text(
                                        AppConstants.noSearchMatches,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            0,
                            AppSpacing.xs,
                            0,
                            88,
                          ),
                          children: [
                            if (pinned.isNotEmpty) ...[
                              const _SectionLabel(
                                label: AppConstants.pinnedSection,
                              ),
                              ...pinned.map(
                                (c) => _ConversationTile(
                                  conversation: c,
                                  selected: c.id == activeId,
                                ),
                              ),
                            ],
                            if (recent.isNotEmpty) ...[
                              const _SectionLabel(
                                label: AppConstants.recentSection,
                              ),
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
              ),
            ],
          ),
          if (showFab)
            Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: _StartNewChat(onPressed: () => _newChat(ref)),
            ),
        ],
      ),
    );
  }
}

bool _matches(WidgetRef ref, Conversation conversation, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return true;
  if (conversation.title.toLowerCase().contains(needle)) return true;

  final messages = ref.read(chatStorageProvider).loadMessages(conversation.id);
  for (final message in messages) {
    if (message.content.toLowerCase().contains(needle)) return true;
  }
  return false;
}

class _StartNewChat extends StatefulWidget {
  const _StartNewChat({required this.onPressed, this.large = false});

  final VoidCallback onPressed;
  final bool large;

  @override
  State<_StartNewChat> createState() => _StartNewChatState();
}

class _StartNewChatState extends State<_StartNewChat> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final fill = isDark ? colors.onSurface : colors.primary;
    final foreground = isDark ? colors.surface : colors.onPrimary;
    final motion = AppMotion.of(context, AppMotion.fast);
    final size = widget.large ? 72.0 : AppSpacing.tap;
    final iconSize = widget.large ? 32.0 : AppSpacing.icon;

    final disc = AnimatedScale(
      scale: _pressed ? 0.94 : 1,
      duration: motion,
      curve: AppMotion.standard,
      child: Material(
        color: fill,
        shape: const CircleBorder(),
        elevation: widget.large ? 0 : 2,
        shadowColor: colors.shadow.withValues(alpha: 0.2),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.onPressed,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(Icons.add, size: iconSize, color: foreground),
          ),
        ),
      ),
    );

    if (!widget.large) {
      return Tooltip(message: AppConstants.startNewChatLabel, child: disc);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        disc,
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: widget.onPressed,
          child: Text(
            AppConstants.startNewChatLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
  const _ConversationTile({required this.conversation, required this.selected});

  final Conversation conversation;
  final bool selected;

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final next = await showDialog<String>(
      context: context,
      builder: (dialogContext) =>
          _RenameChatDialog(initialTitle: conversation.title),
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

  double _taskPreviewHeight(BuildContext context, double width) {
    final style = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600);
    final pinWidth = conversation.isPinned ? 22.0 : 0.0;
    final textWidth = (width - 48 - pinWidth).clamp(0.0, width);
    final painter = TextPainter(
      text: TextSpan(text: conversation.title, style: style),
      maxLines: 3,
      textDirection: Directionality.of(context),
    )..layout(maxWidth: textWidth);
    return painter.height + 56;
  }

  Future<void> _openActions(BuildContext context, WidgetRef ref) async {
    final box = context.findRenderObject()! as RenderBox;
    final anchor = box.localToGlobal(Offset.zero) & box.size;
    HapticFeedback.mediumImpact();
    final action = await HoldMenu.show<_ChatAction>(
      context,
      anchor: anchor,
      preferredHeight: _taskPreviewHeight(context, box.size.width),
      preview: _LiftedTask(
        title: conversation.title,
        pinned: conversation.isPinned,
      ),
      items: [
        HoldMenuItem(
          value: _ChatAction.pin,
          label: conversation.isPinned
              ? AppConstants.unpinChatLabel
              : AppConstants.pinChatLabel,
          icon: Icons.push_pin_outlined,
        ),
        const HoldMenuItem(
          value: _ChatAction.rename,
          label: AppConstants.renameChatLabel,
          icon: Icons.edit_outlined,
        ),
        const HoldMenuItem(
          value: _ChatAction.delete,
          label: AppConstants.deleteChatLabel,
          icon: Icons.delete_outline,
          danger: true,
        ),
      ],
    );
    if (!context.mounted || action == null) return;
    switch (action) {
      case _ChatAction.pin:
        ref.read(chatProvider.notifier).togglePin(conversation.id);
      case _ChatAction.rename:
        await _rename(context, ref);
      case _ChatAction.delete:
        await _delete(context, ref);
    }
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
            ref.read(workspaceTabProvider.notifier).select(WorkspaceTab.agent);
          },
          onLongPress: () => _openActions(context, ref),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
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
                  child: Text(
                    conversation.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
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

enum _ChatAction { pin, rename, delete }

class _LiftedTask extends StatelessWidget {
  const _LiftedTask({required this.title, required this.pinned});

  final String title;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Row(
          children: [
            if (pinned) ...[
              Icon(
                Icons.push_pin_rounded,
                size: 14,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                maxLines: 3,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
