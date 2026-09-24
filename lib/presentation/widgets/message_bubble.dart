import 'package:flutter/material.dart';

import '../../core/models/message.dart';
import '../../core/models/message_status.dart';
import '../theme/app_radii.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isUser = message.role == MessageRole.user;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.82,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: colors.outline),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text(
                message.content,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.92,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content.isEmpty && message.status == MessageStatus.streaming
                  ? '…'
                  : message.content,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
            ),
            if (message.status == MessageStatus.stopped) ...[
              const SizedBox(height: 8),
              Text(
                'Stopped',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            if (message.status == MessageStatus.failed) ...[
              const SizedBox(height: 8),
              Text(
                message.error ?? 'Something went wrong',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
