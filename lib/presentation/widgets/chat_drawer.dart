import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/conversation.dart';
import '../navigation/app_routes.dart';
import '../providers/chat_provider.dart';

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
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppConstants.appName.toLowerCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'New chat',
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go(AppRoutes.home);
                    },
                    style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                    icon: const Icon(Icons.edit_square),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.outline),
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
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Text(
        conversation.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      onTap: () {
        Navigator.of(context).pop();
        context.go(AppRoutes.chatPath(conversation.id));
      },
    );
  }
}
