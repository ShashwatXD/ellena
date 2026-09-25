import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_spacing.dart';

class SkillHubTile extends StatelessWidget {
  const SkillHubTile({
    super.key,
    required this.icon,
    required this.name,
    required this.description,
    this.added = false,
    this.onAdd,
  });

  final IconData icon;
  final String name;
  final String description;
  final bool added;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: colors.onSurface),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (onAdd != null)
            _AddButton(added: added, onPressed: onAdd!)
          else
            Text(
              AppConstants.skillHubAdded,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.added, required this.onPressed});

  final bool added;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final label = added ? AppConstants.skillHubAdded : AppConstants.skillHubAdd;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: added ? colors.onSurfaceVariant : colors.onSurface,
        backgroundColor: added ? colors.surfaceContainerHighest : null,
        side: added
            ? null
            : BorderSide(color: colors.outline, width: AppSpacing.stroke),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: const Size(88, 36),
        tapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        textStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(
        label,
        maxLines: 2,
        textAlign: TextAlign.center,
      ),
    );
  }
}
