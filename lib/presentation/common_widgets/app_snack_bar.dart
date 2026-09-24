import 'package:flutter/material.dart';

import '../theme/app_breakpoints.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

abstract final class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      _build(
        context,
        message: message,
        icon: icon,
        duration: duration,
      ),
    );
  }

  static SnackBar _build(
    BuildContext context, {
    required String message,
    IconData? icon,
    required Duration duration,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final pad = AppBreakpoints.pagePadding(context);

    final bg = colors.inverseSurface;
    final fg = colors.onInverseSurface;
    final fgMuted = fg.withValues(alpha: 0.78);

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.fromLTRB(pad, 0, pad, AppSpacing.md),
      duration: duration,
      content: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: fg.withValues(alpha: 0.08),
            width: AppSpacing.stroke,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fgMuted),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
