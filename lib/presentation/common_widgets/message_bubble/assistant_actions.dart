part of 'message_bubble.dart';

class _AssistantActions extends StatelessWidget {
  const _AssistantActions({
    required this.content,
    required this.showSuccess,
  });

  final String content;
  final bool showSuccess;

  Future<void> _copy(BuildContext context) =>
      ClipboardCopy.copy(context, content);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final motion = AppMotion.of(context, AppMotion.fast);

    return Row(
      children: [
        if (showSuccess)
          _SuccessCue(motion: motion, color: colors.onSurfaceVariant),
        IconButton(
          onPressed: () => _copy(context),
          style: TextButton.styleFrom(
            foregroundColor: colors.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          icon: const Icon(Icons.copy_rounded, size: 15),
        ),
      ],
    );
  }
}

class _SuccessCue extends StatefulWidget {
  const _SuccessCue({required this.motion, required this.color});

  final Duration motion;
  final Color color;

  @override
  State<_SuccessCue> createState() => _SuccessCueState();
}

class _SuccessCueState extends State<_SuccessCue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.motion)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: AppMotion.standard),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1).animate(
          CurvedAnimation(parent: _controller, curve: AppMotion.standard),
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: 16,
            color: widget.color.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
