import 'package:flutter/material.dart';

abstract final class AppBreakpoints {
  static const double compact = 360;
  static const double medium = 400;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < compact) return 12;
    if (width < medium) return 16;
    return 20;
  }

  static double sectionGap(BuildContext context) {
    return isCompact(context) ? 20 : 24;
  }

  static double drawerWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width * 0.86).clamp(260.0, 320.0);
  }

  static double messageMaxFraction({required bool isUser}) =>
      isUser ? 0.82 : 0.94;

  static EdgeInsets viewPadding(BuildContext context) {
    return MediaQuery.viewPaddingOf(context);
  }

  static EdgeInsets paddingOf(BuildContext context) {
    return MediaQuery.paddingOf(context);
  }

  static TextStyle? headlineStyle(BuildContext context, ThemeData theme) {
    final base = theme.textTheme.headlineMedium;
    if (!isCompact(context) || base == null) return base;
    return base.copyWith(fontSize: (base.fontSize ?? 28) * 0.9);
  }
}
