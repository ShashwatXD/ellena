import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration emphasis = Duration(milliseconds: 280);
  static const Duration drawer = Duration(milliseconds: 260);
  static const Duration theme = Duration.zero;

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubic;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;

  static Duration of(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? instant : duration;
  }

  static Widget scaleFadeTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    final curved = CurvedAnimation(parent: animation, curve: standard);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.86, end: 1).animate(curved),
        child: child,
      ),
    );
  }
}
