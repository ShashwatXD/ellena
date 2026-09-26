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
        expanded ? AppSpacing.sm : 0,
        0,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: expanded ? colors.surfaceContainerHighest : colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: colors.outline, width: AppSpacing.stroke),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(expanded ? 10 : 6, 4, 2, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(skill.icon, size: 14, color: colors.onSurface),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  skill.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (expanded
                          ? theme.textTheme.labelLarge
                          : theme.textTheme.labelMedium)
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: AppConstants.removeSkillTooltip,
                onPressed: onClear,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(
                  width: expanded ? 28 : 22,
                  height: expanded ? 28 : 22,
                ),
                icon: Icon(Icons.close, size: 14, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
