import 'package:flutter/material.dart';

class TypingHeadline extends StatefulWidget {
  const TypingHeadline({
    super.key,
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  State<TypingHeadline> createState() => _TypingHeadlineState();
}

class _TypingHeadlineState extends State<TypingHeadline>
    with SingleTickerProviderStateMixin {
  static bool _played = false;

  static const _perCharacter = Duration(milliseconds: 38);

  late final AnimationController _controller;
  int _shown = 0;

  @override
  void initState() {
    super.initState();
    final length = widget.text.length;
    _controller = AnimationController(
      vsync: this,
      duration: _perCharacter * (length == 0 ? 1 : length),
    )..addListener(_onTick);

    if (_played || length == 0) {
      _shown = length;
      _played = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        setState(() => _shown = length);
        _played = true;
        return;
      }
      _controller.forward();
    });
  }

  void _onTick() {
    final length = widget.text.length;
    final next = _controller.isCompleted
        ? length
        : (_controller.value * length).floor().clamp(0, length);
    if (next == _shown) return;
    setState(() => _shown = next);
    if (_controller.isCompleted) _played = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final shown = text.substring(0, _shown.clamp(0, text.length));
    final rest = text.substring(shown.length);

    return Text.rich(
      TextSpan(
        style: widget.style,
        children: [
          TextSpan(text: shown),
          if (rest.isNotEmpty)
            TextSpan(
              text: rest,
              style: const TextStyle(color: Colors.transparent),
            ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
