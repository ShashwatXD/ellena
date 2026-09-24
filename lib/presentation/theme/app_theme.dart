import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final background =
        isLight ? AppColors.backgroundLight : AppColors.backgroundDark;
    final surface = isLight ? AppColors.surfaceLight : AppColors.surfaceDark;
    final onSurface = isLight ? AppColors.ink : AppColors.onDark;
    final muted = AppColors.inkMuted;
    final outline = isLight ? AppColors.line : AppColors.lineDark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.accent,
      onPrimary: AppColors.canvas,
      primaryContainer: isLight ? AppColors.accentSoft : AppColors.accentDeep,
      onPrimaryContainer: isLight ? AppColors.accentDeep : AppColors.accentSoft,
      secondary: AppColors.ink,
      onSecondary: AppColors.canvas,
      secondaryContainer: isLight ? AppColors.line : AppColors.lineDark,
      onSecondaryContainer: onSurface,
      tertiary: AppColors.accentDeep,
      onTertiary: AppColors.canvas,
      error: AppColors.error,
      onError: AppColors.canvas,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: muted,
      surfaceContainerHighest:
          isLight ? AppColors.accentSoft : AppColors.surfaceElevatedDark,
      outline: outline,
      outlineVariant: outline,
      shadow: AppColors.ink.withValues(alpha: isLight ? 0.10 : 0.45),
      scrim: AppColors.ink.withValues(alpha: 0.45),
      inverseSurface: isLight ? AppColors.ink : AppColors.mist,
      onInverseSurface: isLight ? AppColors.mist : AppColors.ink,
      inversePrimary: AppColors.accentSoft,
    );

    final textTheme = AppTypography.textTheme(
      primary: onSurface,
      muted: muted,
    );

    final radiusMd = BorderRadius.circular(AppRadii.md);
    final radiusLg = BorderRadius.circular(AppRadii.lg);
    final radiusSm = BorderRadius.circular(AppRadii.sm);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: surface,
      dividerColor: outline,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: background,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        toolbarHeight: 56,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: surface,
        scrimColor: AppColors.ink.withValues(alpha: isLight ? 0.28 : 0.55),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radiusLg,
          side: BorderSide(color: outline),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: radiusLg),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: onSurface),
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
      dividerTheme: DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.canvas,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: onSurface,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: muted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide(
            color: onSurface.withValues(alpha: 0.45),
            width: 1.5,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isLight ? AppColors.accentSoft : AppColors.accentDeep,
        labelStyle: textTheme.labelMedium!,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: radiusSm),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.canvas,
        elevation: 0,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: onSurface,
        textColor: onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: onSurface,
        circularTrackColor: outline,
      ),
    );
  }
}
