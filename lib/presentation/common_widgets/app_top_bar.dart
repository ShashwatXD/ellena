import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../navigation/app_routes.dart';
import '../providers/providers.dart';
import '../theme/app_spacing.dart';
import 'account_mark.dart';
import 'workspace_tabs.dart';

class AppTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  static const _side = AppSpacing.tap + AppSpacing.sm;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(workspaceTabProvider) == WorkspaceTab.tasks;
    final search = ref.watch(taskSearchProvider);
    final searching = tasks && search.open;
    final colors = Theme.of(context).colorScheme;

    return AppBar(
      systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      centerTitle: !searching,
      leadingWidth: _side,
      titleSpacing: searching ? AppSpacing.xs : 0,
      leading: IconButton(
        tooltip: AppConstants.accountTooltip,
        onPressed: () {
          HapticFeedback.selectionClick();
          context.push(AppRoutes.account);
        },
        icon: const AccountMark(),
      ),
      title: searching ? const _TaskSearchField() : const WorkspaceTabs(),
      actions: [
        SizedBox(
          width: _side,
          child: searching
              ? _TopBarIcon(
                  tooltip: AppConstants.closeSearchTooltip,
                  icon: Icons.close,
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    ref.read(taskSearchProvider.notifier).close();
                  },
                )
              : tasks
                  ? _TopBarIcon(
                      tooltip: AppConstants.searchTooltip,
                      icon: Icons.search,
                      color: colors.onSurface,
                      onTap: () {
                        ref.read(taskSearchProvider.notifier).open();
                      },
                    )
                  : null,
        ),
      ],
    );
  }
}

class _TopBarIcon extends StatelessWidget {
  const _TopBarIcon({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Icon(icon, color: color),
        ),
      ),
    );
  }
}

class _TaskSearchField extends ConsumerStatefulWidget {
  const _TaskSearchField();

  @override
  ConsumerState<_TaskSearchField> createState() => _TaskSearchFieldState();
}

class _TaskSearchFieldState extends ConsumerState<_TaskSearchField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(taskSearchProvider).query);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textInputAction: TextInputAction.search,
      style: theme.textTheme.bodyLarge,
      cursorColor: colors.onSurface,
      onChanged: ref.read(taskSearchProvider.notifier).setQuery,
      decoration: InputDecoration(
        isCollapsed: true,
        hintText: AppConstants.searchHint,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: colors.onSurfaceVariant,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
