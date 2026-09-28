import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class PixelField extends StatefulWidget {
  const PixelField({super.key});

  @override
  State<PixelField> createState() => _PixelFieldState();
}

class _PixelFieldState extends State<PixelField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      return CustomPaint(painter: _PixelPainter(0, ink));
    }
    return AnimatedBuilder(
      animation: _motion,
      builder: (context, child) {
        return CustomPaint(painter: _PixelPainter(_motion.value, ink));
      },
    );
  }
}

class _PixelPainter extends CustomPainter {
  const _PixelPainter(this.t, this.ink);

  final double t;
  final Color ink;

  static const _gap = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final phase = t * math.pi * 2;
    final rings = <({double cx, double cy, Color color, double spin})>[
      (cx: 0.22, cy: 0.22, color: AppColors.avatarBlue, spin: 1),
      (cx: 0.16, cy: 0.7, color: AppColors.markPink, spin: -1.2),
      (cx: 0.82, cy: 0.48, color: AppColors.markYellow, spin: 0.85),
    ];
    const scales = <double>[0.12, 0.24, 0.38];
    final unit = math.min(size.width, size.height);

    for (var x = _gap; x < size.width; x += _gap) {
      for (var y = _gap; y < size.height; y += _gap) {
        paint.color = ink.withValues(alpha: 0.07);
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 2, height: 2),
          paint,
        );
        for (final ring in rings) {
          final dx = x - ring.cx * size.width;
          final dy = y - ring.cy * size.height;
          final dist = math.sqrt(dx * dx + dy * dy);
          final angle = math.atan2(dy, dx);
          for (final scale in scales) {
            final band = (dist - unit * scale).abs();
            if (band > _gap * 0.7) continue;
            final dash = math.sin(angle * 6 - phase * ring.spin);
            if (dash < 0.2) continue;
            final alpha = (0.28 + 0.5 * dash) * (1 - band / (_gap * 0.7));
            paint.color = ring.color.withValues(alpha: alpha.clamp(0.18, 0.8));
            canvas.drawRect(
              Rect.fromCenter(center: Offset(x, y), width: 2.6, height: 2.6),
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.ink != ink;
}
