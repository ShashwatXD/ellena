import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/agent_skill.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';

class ComposerSkillChip extends StatelessWidget {
  const ComposerSkillChip({
    super.key,
    required this.skill,
    required this.expanded,
    required this.onClear,
  });

  final AgentSkill skill;
  final bool expanded;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        expanded ? AppSpacing.sm : 0,
        expanded ? AppSpacing.sm : 0,
        expanded ? AppSpacing.sm : AppSpacing.xxs,
        0,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: expanded ? colors.surfaceContainerHighest : colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: colors.outline, width: AppSpacing.stroke),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(expanded ? 10 : 8, 4, 2, 4),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(skill.icon, size: 14, color: colors.onSurface),
              const SizedBox(width: 6),
              if (expanded)
                Expanded(
                  child: Text(
                    skill.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Text(
                  skill.name,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              IconButton(
                tooltip: AppConstants.removeSkillTooltip,
                onPressed: onClear,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                icon: Icon(Icons.close, size: 14, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
