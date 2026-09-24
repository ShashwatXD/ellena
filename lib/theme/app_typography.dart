import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextTheme textTheme({
    required Color primary,
    required Color muted,
  }) {
    final display = GoogleFonts.libreBaskervilleTextTheme();
    final body = GoogleFonts.dmSansTextTheme();

    return TextTheme(
      displayLarge: display.displayLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      displayMedium: display.displayMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: display.displaySmall?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: body.titleLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: body.titleMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: body.titleSmall?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: body.bodyLarge?.copyWith(color: primary, height: 1.5),
      bodyMedium: body.bodyMedium?.copyWith(color: primary, height: 1.5),
      bodySmall: body.bodySmall?.copyWith(color: muted, height: 1.45),
      labelLarge: body.labelLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: body.labelMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: body.labelSmall?.copyWith(color: muted),
    );
  }
}
