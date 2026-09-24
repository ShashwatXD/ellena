import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../navigation/app_routes.dart';
import '../providers/providers.dart';
import '../theme/app_breakpoints.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  void _mockTap(BuildContext context) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppConstants.comingSoonMock),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        centerTitle: true,
        leadingWidth: AppBreakpoints.isCompact(context) ? 56 : 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm),
          child: Center(
            child: _CircleIconButton(
              tooltip: AppConstants.backTooltip,
              icon: Icons.chevron_left_rounded,
              onPressed: () {
                HapticFeedback.selectionClick();
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.home);
                }
              },
            ),
          ),
        ),
        title: Text(
          AppConstants.settingsTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: _ThemeToggleButton(),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppBreakpoints.pagePadding(context),
            AppSpacing.sm,
            AppBreakpoints.pagePadding(context),
            AppSpacing.xxl,
          ),
          children: [
          _SettingsCard(
            onTap: () => _mockTap(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.avatarBlue,
                    ),
                    child: Text(
                      AppConstants.mockUserName[0].toUpperCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.mockUserName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppConstants.mockUserEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SettingsCard(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppConstants.mockPlanName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      FilledButton(
                        onPressed: () => _mockTap(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.onSurface,
                          foregroundColor: colors.surface,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                          textStyle: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text(AppConstants.upgradeLabel),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: AppSpacing.stroke,
                  color: colors.outline.withValues(alpha: 0.7),
                ),
                _MenuTile(
                  icon: Icons.auto_awesome_outlined,
                  label: AppConstants.creditsLabel,
                  trailing: Text(
                    AppConstants.creditsValue,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  onTap: () => _mockTap(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SettingsCard(
            child: Column(
              children: [
                for (var i = 0; i < _menuItems.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: AppSpacing.stroke,
                      indent: 52,
                      color: colors.outline.withValues(alpha: 0.7),
                    ),
                  _MenuTile(
                    icon: _menuItems[i].icon,
                    label: _menuItems[i].label,
                    onTap: () => _mockTap(context),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _DeleteAllChatsButton(
            onConfirm: () async {
              await ref.read(chatProvider.notifier).deleteAllChats();
              if (!context.mounted) return;
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppConstants.deleteAllChatsDone),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
              context.go(AppRoutes.home);
            },
          ),
          ],
        ),
      ),
    );
  }
}

const _menuItems = <({IconData icon, String label})>[
  (icon: Icons.schedule_rounded, label: AppConstants.settingsScheduledTasks),
  (icon: Icons.lightbulb_outline_rounded, label: AppConstants.settingsKnowledge),
  (icon: Icons.mail_outline_rounded, label: AppConstants.settingsMail),
  (icon: Icons.storage_outlined, label: AppConstants.settingsDataControls),
  (icon: Icons.web_asset_rounded, label: AppConstants.settingsCloudBrowser),
  (icon: Icons.extension_outlined, label: AppConstants.settingsSkills),
  (icon: Icons.power_outlined, label: AppConstants.settingsConnectors),
  (
    icon: Icons.electrical_services_outlined,
    label: AppConstants.settingsIntegrations
  ),
];

class _DeleteAllChatsButton extends StatelessWidget {
  const _DeleteAllChatsButton({required this.onConfirm});

  final Future<void> Function() onConfirm;

  Future<void> _confirm(BuildContext context) async {
    HapticFeedback.selectionClick();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colors = theme.colorScheme;
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          title: Text(
            AppConstants.deleteAllChatsTitle,
            style: theme.textTheme.titleLarge,
          ),
          content: Text(
            AppConstants.deleteAllChatsBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppConstants.deleteAllChatsCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: colors.error),
              child: const Text(AppConstants.deleteAllChatsConfirm),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _confirm(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.error,
          side: BorderSide(color: colors.error.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
        child: Text(
          AppConstants.deleteAllChatsLabel,
          style: theme.textTheme.labelLarge?.copyWith(color: colors.error),
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends ConsumerWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: isDark ? AppConstants.themeLight : AppConstants.themeDark,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(themeModeProvider.notifier).setMode(
                  isDark ? ThemeMode.light : ThemeMode.dark,
                );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface,
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.85),
                width: AppSpacing.stroke,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                key: ValueKey(isDark),
                size: 20,
                color: colors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.surface,
        shape: CircleBorder(
          side: BorderSide(
            color: colors.outline.withValues(alpha: 0.85),
            width: AppSpacing.stroke,
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 22, color: colors.onSurface),
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: card,
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colors.onSurface),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(label, style: theme.textTheme.bodyLarge),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 4),
            ],
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
