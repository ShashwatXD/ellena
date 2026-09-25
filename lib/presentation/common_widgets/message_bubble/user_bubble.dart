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
      child: Text(message.content, style: theme.textTheme.bodyLarge),
    );
  }
}
