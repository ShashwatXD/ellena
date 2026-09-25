import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/chat_attachment.dart';
import '../../core/models/mock_stream_scenario.dart';
import '../providers/providers.dart';
import '../theme/app_breakpoints.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import 'app_bottom_sheet.dart';
import '../utils/chat_media.dart';

class AddToChatSheet extends ConsumerWidget {
  const AddToChatSheet({super.key, required this.onPrompt});

  final ValueChanged<String> onPrompt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pad = AppBreakpoints.pagePadding(context);
    final mock = ref.watch(useFakeStreamProvider);

    return AppBottomSheet(
      title: AppConstants.addToChatTitle,
      showClose: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, AppSpacing.xs, 0, AppSpacing.lg),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    icon: Icons.photo_camera_outlined,
                    label: AppConstants.addCamera,
                    onTap: () => _pick(context, ref, ChatMedia.camera),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionTile(
                    icon: Icons.image_outlined,
                    label: AppConstants.addPicture,
                    onTap: () => _pick(context, ref, ChatMedia.picture),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionTile(
                    icon: Icons.attach_file,
                    label: AppConstants.addFile,
                    onTap: () => _pick(context, ref, ChatMedia.pdf),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SheetRow(
            icon: Icons.hub_outlined,
            label: AppConstants.settingsSkills,
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
              ref.read(skillPickerProvider.notifier).open();
            },
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
          if (mock) ...[
            const Divider(),
            for (final scenario in MockStreamScenario.all)
              _SheetRow(
                icon: scenario.icon,
                label: scenario.label,
                onTap: () => _chooseScenario(context, ref, scenario),
              ),
          ],
        ],
      ),
    );
  }

  void _chooseScenario(
    BuildContext context,
    WidgetRef ref,
    MockStreamScenario scenario,
  ) {
    ref.read(mockStreamScenarioProvider.notifier).select(scenario);
    HapticFeedback.selectionClick();
    Navigator.of(context).pop();
    onPrompt(scenario.label);
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    Future<ChatAttachment?> Function(BuildContext context) choose,
  ) async {
    final attachment = await choose(context);
    if (attachment == null || !context.mounted) return;
    ref.read(composerAttachmentProvider.notifier).set(attachment);
    Navigator.of(context).pop();
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
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
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.icon,
    required this.label,
    this.badge,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
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
      ),
    );
  }
}
