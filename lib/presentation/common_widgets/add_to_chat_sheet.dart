import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../theme/app_breakpoints.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import 'app_bottom_sheet.dart';

class AddToChatSheet extends StatelessWidget {
  const AddToChatSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = AppBreakpoints.pagePadding(context);

    return AppBottomSheet(
      title: AppConstants.addToChatTitle,
      showClose: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, AppSpacing.xs, 0, AppSpacing.lg),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: const Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    icon: Icons.photo_camera_outlined,
                    label: AppConstants.addCamera,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionTile(
                    icon: Icons.image_outlined,
                    label: AppConstants.addPicture,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionTile(
                    icon: Icons.attach_file,
                    label: AppConstants.addFile,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _SheetRow(
            icon: Icons.hub_outlined,
            label: AppConstants.settingsSkills,
          ),
          Divider(),
          _SheetRow(
            icon: Icons.image_outlined,
            label: AppConstants.addCreateImage,
          ),
          _SheetRow(
            icon: Icons.auto_fix_high_outlined,
            label: AppConstants.addEditImage,
          ),
          _SheetRow(
            icon: Icons.graphic_eq,
            label: AppConstants.addGenerateAudio,
          ),
          _SheetRow(
            icon: Icons.smart_display_outlined,
            label: AppConstants.addCreateVideo,
          ),
          Divider(),
          _SheetRow(
            icon: Icons.sports_esports_outlined,
            label: AppConstants.addCreateGames,
            badge: AppConstants.addNewBadge,
          ),
          _SheetRow(
            icon: Icons.folder_outlined,
            label: AppConstants.addCreateSlides,
          ),
          _SheetRow(
            icon: Icons.web_asset_outlined,
            label: AppConstants.addBuildWebsite,
          ),
          _SheetRow(
            icon: Icons.smartphone_outlined,
            label: AppConstants.addDevelopApps,
          ),
          _SheetRow(
            icon: Icons.grid_on_outlined,
            label: AppConstants.addCreateSpreadsheet,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        children: [
          Icon(icon, size: 26, color: colors.onSurface),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.icon,
    required this.label,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppBreakpoints.pagePadding(context),
        vertical: 14,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: colors.onSurface),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.avatarBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                badge!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.avatarBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
