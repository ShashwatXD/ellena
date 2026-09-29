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
    this.onAdd,
    this.onRemove,
  });

  final IconData icon;
  final String name;
  final String description;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final canRemove = onRemove != null;
    final canAdd = onAdd != null;

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
          if (canRemove)
            _ActionButton(
              label: AppConstants.skillHubRemove,
              filled: true,
              onPressed: onRemove!,
            )
          else if (canAdd)
            _ActionButton(
              label: AppConstants.skillHubAdd,
              filled: false,
              onPressed: onAdd!,
            )
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: filled ? colors.onSurfaceVariant : colors.onSurface,
        backgroundColor: filled ? colors.surfaceContainerHighest : null,
        side: filled
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
