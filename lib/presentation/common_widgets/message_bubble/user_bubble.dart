part of 'message_bubble.dart';

class _UserBubble extends StatelessWidget {
  const _UserBubble({
    required this.message,
    required this.maxWidth,
    required this.theme,
    this.onLongPress,
  });

  final Message message;
  final double maxWidth;
  final ThemeData theme;
  final void Function(BuildContext bubbleContext)? onLongPress;

  @override
  Widget build(BuildContext context) {
    return _MessageBlock(
      user: true,
      maxWidth: maxWidth,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.attachment != null) ...[
            _UserFile(attachment: message.attachment!),
            if (message.content.isNotEmpty) const SizedBox(height: AppSpacing.xs),
          ],
          if (message.content.isNotEmpty)
            Text(message.content, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _UserFile extends StatelessWidget {
  const _UserFile({required this.attachment});

  final ChatAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (!attachment.isImage) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.picture_as_pdf_outlined, size: 18, color: colors.onSurface),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              attachment.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Image.file(
        File(attachment.path),
        width: 180,
        height: 140,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Text(attachment.name);
        },
      ),
    );
  }
}
