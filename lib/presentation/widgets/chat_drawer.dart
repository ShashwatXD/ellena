import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/conversation.dart';
import '../navigation/app_routes.dart';
import '../providers/providers.dart';
import '../theme/app_spacing.dart';

class ChatDrawer extends ConsumerWidget {
  const ChatDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final conversations = ref.watch(chatProvider).conversations;
    final pinned = conversations.where((c) => c.isPinned).toList();
    final recent = conversations.where((c) => !c.isPinned).toList();

    return Drawer(
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 8, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppConstants.appName.toLowerCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.35,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'New chat',
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop();
                      context.go(AppRoutes.home);
                    },
                    style: IconButton.styleFrom(
                      minimumSize: const Size(AppSpacing.tap, AppSpacing.tap),
                    ),
                    icon: const Icon(Icons.edit_square, size: 20),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: AppSpacing.stroke, color: colors.outline),
            Expanded(
              child: conversations.isEmpty
                  ? Center(
                      child: Text(
                        'No chats yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      children: [
                        if (pinned.isNotEmpty) ...[
                          const _SectionLabel(label: 'Pinned'),
                          ...pinned.map((c) => _ConversationTile(conversation: c)),
                        ],
                        if (recent.isNotEmpty) ...[
                          const _SectionLabel(label: 'Recent'),
                          ...recent.map((c) => _ConversationTile(conversation: c)),
                        ],
                      ],
                    ),
            ),
          ],
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

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      minVerticalPadding: 10,
      title: Text(
        conversation.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge,
      ),
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).pop();
        context.go(AppRoutes.chatPath(conversation.id));
      },
    );
  }
}
