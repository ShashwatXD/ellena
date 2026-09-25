import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/agent_skill.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';

class SkillPicker extends StatelessWidget {
  const SkillPicker({
    super.key,
    required this.query,
    required this.skills,
    required this.onSelected,
    required this.onOpenHub,
  });

  static const heightFactor = 0.20;

  final String query;
  final List<AgentSkill> skills;
  final ValueChanged<AgentSkill> onSelected;
  final VoidCallback onOpenHub;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final skills = AgentSkills.matching(query, from: this.skills);
    final maxHeight = MediaQuery.sizeOf(context).height * heightFactor;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xxs,
                  AppSpacing.xxs,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppConstants.settingsSkills,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: AppConstants.skillHubOpenTooltip,
                      onPressed: onOpenHub,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.settings_outlined,
                        size: 20,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: (maxHeight - 48).clamp(0, maxHeight).toDouble(),
                ),
                child: skills.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.md,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppConstants.noSkillsLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: skills.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: colors.outline),
                        itemBuilder: (context, index) {
                          final skill = skills[index];
                          return InkWell(
                            onTap: () => onSelected(skill),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    skill.icon,
                                    size: 20,
                                    color: colors.onSurface,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          skill.name,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          skill.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
