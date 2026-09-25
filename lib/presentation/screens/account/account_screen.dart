import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../navigation/app_routes.dart';
import '../../providers/providers.dart';
import '../../theme/app_breakpoints.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../../common_widgets/app_snack_bar.dart';
import 'utils/account_menu_items.dart';
import 'widgets/account_circle_icon_button.dart';
import 'widgets/account_delete_chats_button.dart';
import 'widgets/account_menu_tile.dart';
import 'widgets/account_mock_responses_card.dart';
import 'widgets/account_settings_card.dart';
import 'widgets/account_theme_toggle.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  void _mockTap(BuildContext context) {
    HapticFeedback.selectionClick();
    AppSnackBar.show(
      context,
      message: AppConstants.comingSoonMock,
      icon: Icons.schedule_rounded,
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
            child: AccountCircleIconButton(
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
            child: AccountThemeToggle(),
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
          AccountSettingsCard(
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
                      color: AppColors.ink,
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
          AccountSettingsCard(
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
                AccountMenuTile(
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
          AccountSettingsCard(
            child: Column(
              children: [
                for (var i = 0; i < accountMenuItems.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: AppSpacing.stroke,
                      indent: 52,
                      color: colors.outline.withValues(alpha: 0.7),
                    ),
                  AccountMenuTile(
                    icon: accountMenuItems[i].icon,
                    label: accountMenuItems[i].label,
                    onTap: () {
                      if (accountMenuItems[i].label ==
                          AppConstants.skillHubTitle) {
                        HapticFeedback.selectionClick();
                        context.push(AppRoutes.skillHub);
                        return;
                      }
                      _mockTap(context);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AccountDeleteChatsButton(
            onConfirm: () async {
              await ref.read(chatProvider.notifier).deleteAllChats();
              if (!context.mounted) return;
              HapticFeedback.mediumImpact();
              AppSnackBar.show(
                context,
                message: AppConstants.deleteAllChatsDone,
                icon: Icons.check_rounded,
              );
              context.go(AppRoutes.home);
            },
          ),
          if (ref.watch(mockControlsAvailableProvider)) ...[
            const SizedBox(height: AppSpacing.sm),
            const AccountMockResponsesCard(),
          ],
          ],
        ),
      ),
    );
  }
}
