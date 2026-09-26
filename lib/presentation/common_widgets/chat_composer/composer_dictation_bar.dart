part of 'chat_composer.dart';

class _DictationBar extends StatelessWidget {
  const _DictationBar({
    required this.level,
    required this.onDone,
  });

  final double level;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.xxs,
          AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: _SpeechWave(
                level: level,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            _RoundIconButton(
              tooltip: AppConstants.dictationDoneTooltip,
              icon: Icons.check_rounded,
              onPressed: onDone,
              foreground: isDark ? colors.surface : colors.onPrimary,
              filled: true,
              fillColor: isDark ? colors.onSurface : colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeechWave extends StatefulWidget {
  const _SpeechWave({required this.level, required this.color});

  final double level;
  final Color color;

  @override
  State<_SpeechWave> createState() => _SpeechWaveState();
}

class _SpeechWaveState extends State<_SpeechWave>
    with SingleTickerProviderStateMixin {
  static const _bars = 32;
  static const _rest = 0.08;

  final List<double> _levels = List<double>.filled(_bars, _rest, growable: true);
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1000000;
    _last = elapsed;
    if (!mounted || dt <= 0 || dt > 0.1) return;
    final level = widget.level.clamp(0.0, 1.0);
    if (level > 0.1) {
      _offset += dt * 8;
      _levels[_levels.length - 1] = level;
      while (_offset >= 1) {
        _offset -= 1;
        _levels
          ..removeAt(0)
          ..add(level);
      }
      setState(() {});
      return;
    }
    var moving = _offset > 0;
    _offset = 0;
    for (var i = 0; i < _levels.length; i++) {
      final next = _levels[i] + (_rest - _levels[i]) * (dt * 6).clamp(0.0, 1.0);
      if ((next - _levels[i]).abs() > 0.002) moving = true;
      _levels[i] = next;
    }
    if (moving) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpeechWavePainter(
        levels: _levels,
        offset: _offset,
        color: widget.color,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _SpeechWavePainter extends CustomPainter {
  const _SpeechWavePainter({
    required this.levels,
    required this.offset,
    required this.color,
  });

  final List<double> levels;
  final double offset;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || levels.isEmpty) return;
    const gap = 3.0;
    final count = levels.length;
    final barWidth = ((size.width - gap * (count - 1)) / count).clamp(2.0, 8.0);
    final step = barWidth + gap;
    final paint = Paint()..color = color.withValues(alpha: 0.88);
    for (var i = 0; i < count; i++) {
      final height = (levels[i].clamp(0.08, 1.0)) * size.height;
      final left = i * step - offset * step;
      final top = (size.height - height) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth, height),
          const Radius.circular(99),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpeechWavePainter oldDelegate) => true;
}