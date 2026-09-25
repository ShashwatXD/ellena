import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../theme/app_breakpoints.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.centeredTitle = true,
    this.showClose = false,
    this.heightFactor = 0.48,
  });

  final Widget child;
  final String? title;
  final bool centeredTitle;
  final bool showClose;
  final double heightFactor;

  static Future<void> show(
    BuildContext context, {
    required WidgetBuilder builder,
    Color? backgroundColor,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: backgroundColor ?? colors.surface,
      barrierColor: colors.scrim.withValues(alpha: isDark ? 0.55 : 0.28),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * heightFactor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
            if (title != null) _header(context, theme),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, ThemeData theme) {
    final titleWidget = Text(
      title!,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
    if (!centeredTitle) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          AppBreakpoints.pagePadding(context),
          AppSpacing.md,
          AppBreakpoints.pagePadding(context),
          AppSpacing.sm,
        ),
        child: Align(alignment: Alignment.centerLeft, child: titleWidget),
      );
    }

    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          titleWidget,
          if (showClose)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: AppConstants.closeTooltip,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
        ],
      ),
    );
  }
}
