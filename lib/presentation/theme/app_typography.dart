import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextTheme textTheme({
    required Color primary,
    required Color muted,
  }) {
    final display = GoogleFonts.libreBaskervilleTextTheme();
    final body = _bodyTextTheme();

    return TextTheme(
      displayLarge: display.displayLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 40,
        height: 1.15,
        letterSpacing: -0.8,
      ),
      displayMedium: display.displayMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 32,
        height: 1.2,
        letterSpacing: -0.6,
      ),
      displaySmall: display.displaySmall?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 28,
        height: 1.2,
        letterSpacing: -0.4,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 28,
        height: 1.2,
        letterSpacing: -0.4,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 26,
        height: 1.25,
        letterSpacing: -0.35,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 22,
        height: 1.25,
        letterSpacing: -0.3,
      ),
      titleLarge: body.titleLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        letterSpacing: -0.2,
      ),
      titleMedium: body.titleMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: -0.1,
      ),
      titleSmall: body.titleSmall?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      bodyLarge: body.bodyLarge?.copyWith(
        color: primary,
        fontSize: 16,
        height: 1.55,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        color: primary,
        fontSize: 15,
        height: 1.5,
      ),
      bodySmall: body.bodySmall?.copyWith(
        color: muted,
        fontSize: 13,
        height: 1.45,
      ),
      labelLarge: body.labelLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: 0,
      ),
      labelMedium: body.labelMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      labelSmall: body.labelSmall?.copyWith(
        color: muted,
        fontWeight: FontWeight.w500,
        fontSize: 11,
      ),
    );
  }

  static TextStyle codeStyle(Color color) {
    return GoogleFonts.jetBrainsMono(
      color: color,
      fontSize: 13,
      height: 1.45,
    );
  }

  static TextTheme _bodyTextTheme() {
    if (!kIsWeb && Platform.isIOS) {
      return const TextTheme(
        bodyLarge: TextStyle(fontFamily: '.SF Pro Text'),
        bodyMedium: TextStyle(fontFamily: '.SF Pro Text'),
        bodySmall: TextStyle(fontFamily: '.SF Pro Text'),
        titleLarge: TextStyle(fontFamily: '.SF Pro Text'),
        titleMedium: TextStyle(fontFamily: '.SF Pro Text'),
        titleSmall: TextStyle(fontFamily: '.SF Pro Text'),
        labelLarge: TextStyle(fontFamily: '.SF Pro Text'),
        labelMedium: TextStyle(fontFamily: '.SF Pro Text'),
        labelSmall: TextStyle(fontFamily: '.SF Pro Text'),
      );
    }
    return GoogleFonts.interTextTheme();
  }
}
