part of 'message_bubble.dart';

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    final reduce = MediaQuery.disableAnimationsOf(context);

    if (reduce) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (_) {
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 5, top: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          );
        }),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final t = (_controller.value + index * 0.18) % 1.0;
            final bounce = (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
            return Transform.translate(
              offset: Offset(0, -3.5 * bounce),
              child: Opacity(
                opacity: 0.35 + 0.65 * bounce,
                child: Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 5, top: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
