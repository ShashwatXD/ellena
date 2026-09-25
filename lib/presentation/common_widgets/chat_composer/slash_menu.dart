import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import 'skill_picker.dart';

class SlashMenu extends StatelessWidget {
  const SlashMenu({
    super.key,
    required this.query,
    required this.onSkills,
  });

  final String query;
  final VoidCallback onSkills;

  bool get _showsSkills {
    final needle = query.trim().toLowerCase();
    return needle.isEmpty || 'skills'.startsWith(needle);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final maxHeight =
        MediaQuery.sizeOf(context).height * SkillPicker.heightFactor;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Material(
          color: colors.surface,
          elevation: 6,
          shadowColor: colors.shadow.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          clipBehavior: Clip.antiAlias,
          child: _showsSkills
              ? InkWell(
                  onTap: onSkills,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.hub_outlined, size: 20, color: colors.onSurface),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            AppConstants.settingsSkills,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Text(
                    AppConstants.noSkillsLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
