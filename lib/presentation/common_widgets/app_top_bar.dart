import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../navigation/app_routes.dart';
import '../theme/app_spacing.dart';
import 'chat_shell.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.actions,
    this.showAccount = true,
  });

  final Widget title;
  final List<Widget>? actions;
  final bool showAccount;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final initial = AppConstants.mockUserName.isNotEmpty
        ? AppConstants.mockUserName[0].toUpperCase()
        : '?';

    return AppBar(
      systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      leading: IconButton(
        tooltip: AppConstants.menuTooltip,
        onPressed: () {
          HapticFeedback.selectionClick();
          ChatShell.scaffoldKey.currentState?.openDrawer();
        },
        style: IconButton.styleFrom(
          minimumSize: const Size(AppSpacing.tap, AppSpacing.tap),
          foregroundColor: colors.onSurface,
        ),
        icon: const Icon(Icons.menu_rounded, size: 22),
      ),
      title: title,
      titleSpacing: 0,
      actions: [
        ...?actions,
        if (showAccount)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: IconButton(
              tooltip: AppConstants.accountTooltip,
              onPressed: () {
                HapticFeedback.selectionClick();
                context.push(AppRoutes.account);
              },
              style: IconButton.styleFrom(
                minimumSize: const Size(AppSpacing.tap, AppSpacing.tap),
              ),
              icon: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary,
                ),
                child: Text(
                  initial,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
