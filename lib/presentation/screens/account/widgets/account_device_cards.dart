import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../data/storage/app_storage.dart';
import '../../../../data/storage/storage_keys.dart';
import '../../../common_widgets/app_snack_bar.dart';
import '../../../navigation/app_routes.dart';
import '../../../providers/providers.dart';
import '../../../theme/app_spacing.dart';
import 'account_menu_tile.dart';
import 'account_settings_card.dart';

class AccountDeviceCards extends ConsumerStatefulWidget {
  const AccountDeviceCards({super.key});

  @override
  ConsumerState<AccountDeviceCards> createState() => _AccountDeviceCardsState();
}

class _AccountDeviceCardsState extends ConsumerState<AccountDeviceCards> {
  Future<void> _pickAppearance(BuildContext tileContext, ThemeMode mode) async {
    HapticFeedback.selectionClick();
    final box = tileContext.findRenderObject()! as RenderBox;
    final overlay = Navigator.of(tileContext).overlay!.context.findRenderObject()! as RenderBox;
    final origin = box.localToGlobal(Offset.zero, ancestor: overlay);
    final anchor = Rect.fromLTWH(
      origin.dx + box.size.width,
      origin.dy,
      0,
      box.size.height,
    );
    final picked = await showMenu<ThemeMode>(
      context: tileContext,
      position: RelativeRect.fromRect(anchor, Offset.zero & overlay.size),
      items: [
        for (final choice in const [
          ThemeMode.system,
          ThemeMode.dark,
          ThemeMode.light,
        ])
          PopupMenuItem(
            value: choice,
            child: Row(
              children: [
                Expanded(child: Text(_appearanceLabel(choice))),
                if (choice == mode)
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Theme.of(tileContext).colorScheme.onSurface,
                  ),
              ],
            ),
          ),
      ],
    );
    if (picked == null || picked == mode) return;
    await ref.read(themeModeProvider.notifier).setMode(picked);
  }

  String _appearanceLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => AppConstants.themeFollowSystem,
      ThemeMode.light => AppConstants.themeLight,
      ThemeMode.dark => AppConstants.themeDark,
    };
  }

  void _clearCache() {
    HapticFeedback.selectionClick();
    final cache = PaintingBinding.instance.imageCache;
    cache.clear();
    cache.clearLiveImages();
    setState(() {});
    AppSnackBar.show(
      context,
      message: AppConstants.settingsClearCache,
      icon: Icons.check_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mode = ref.watch(themeModeProvider);
    final appearance = _appearanceLabel(mode);
    final cacheBytes = PaintingBinding.instance.imageCache.currentSizeBytes;
    final dividerColor = colors.outline.withValues(alpha: 0.7);
    Widget divider() {
      return Divider(
        height: 1,
        thickness: AppSpacing.stroke,
        indent: 52,
        color: dividerColor,
      );
    }

    final valueStyle = theme.textTheme.bodyLarge?.copyWith(
      color: colors.onSurfaceVariant,
    );

    return Column(
      children: [
        AccountSettingsCard(
          child: Column(
            children: [
              AccountMenuTile(
                icon: Icons.language_rounded,
                label: AppConstants.settingsLanguage,
                trailing: Text(
                  AppConstants.settingsLanguageValue,
                  style: valueStyle,
                ),
                onTap: () => _soon(context),
              ),
              divider(),
              AccountMenuTile(
                icon: Icons.dark_mode_outlined,
                label: AppConstants.settingsAppearance,
                showChevron: false,
                trailing: Builder(
                  builder: (menuContext) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _pickAppearance(menuContext, mode),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(appearance, style: valueStyle),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.unfold_more_rounded,
                                size: 20,
                                color: colors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              divider(),
              AccountMenuTile(
                icon: Icons.cleaning_services_outlined,
                label: AppConstants.settingsClearCache,
                trailing: Text(_formatBytes(cacheBytes), style: valueStyle),
                onTap: _clearCache,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AccountSettingsCard(
          child: Column(
            children: [
              AccountMenuTile(
                icon: Icons.favorite_border_rounded,
                label: AppConstants.settingsRateApp,
                showChevron: false,
                trailing: Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
                onTap: () => _soon(context),
              ),
              divider(),
              AccountMenuTile(
                icon: Icons.help_outline_rounded,
                label: AppConstants.settingsGetHelp,
                showChevron: false,
                trailing: Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
                onTap: () => _soon(context),
              ),
              divider(),
              AccountMenuTile(
                icon: Icons.info_outline_rounded,
                label: AppConstants.settingsVersion,
                showChevron: false,
                trailing: Text(
                  AppConstants.settingsVersionValue,
                  style: valueStyle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AccountSettingsCard(
          child: AccountMenuTile(
            icon: Icons.logout_rounded,
            label: AppConstants.settingsLogOut,
            showChevron: false,
            onTap: () async {
              HapticFeedback.selectionClick();
              await AppStorage.save(StorageKeys.signedIn, false);
              if (!context.mounted) return;
              context.go(AppRoutes.welcome);
            },
          ),
        ),
      ],
    );
  }

  void _soon(BuildContext context) {
    HapticFeedback.selectionClick();
    AppSnackBar.show(
      context,
      message: AppConstants.comingSoonMock,
      icon: Icons.schedule_rounded,
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.round()} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}
