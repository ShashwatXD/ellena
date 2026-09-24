import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_spacing.dart';
import 'chat_shell.dart';

class EllenaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EllenaAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  final Widget title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppBar(
      leading: IconButton(
        tooltip: 'Menu',
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
      actions: actions,
    );
  }
}
