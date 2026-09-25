import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';

class ComposerQuoteBar extends StatelessWidget {
  const ComposerQuoteBar({
    super.key,
    required this.text,
    required this.expanded,
    required this.onClear,
  });

  final String text;
  final bool expanded;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        expanded ? AppSpacing.sm : AppSpacing.xs,
        expanded ? AppSpacing.sm : AppSpacing.xxs,
        AppSpacing.xxs,
        0,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(
            expanded ? AppRadii.md : AppRadii.pill,
          ),
          border: expanded
              ? Border(left: BorderSide(color: colors.onSurface, width: 2))
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            expanded ? AppSpacing.sm : AppSpacing.md,
            expanded ? AppSpacing.sm : 6,
            AppSpacing.xxs,
            expanded ? AppSpacing.sm : 6,
          ),
          child: Row(
            crossAxisAlignment: expanded
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  text,
                  maxLines: expanded ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (expanded
                              ? theme.textTheme.bodyMedium
                              : theme.textTheme.labelMedium)
                          ?.copyWith(
                            color: colors.onSurfaceVariant,
                            height: expanded ? 1.4 : 1.2,
                            fontStyle: expanded
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                ),
              ),
              IconButton(
                tooltip: AppConstants.removeQuoteTooltip,
                onPressed: onClear,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                icon: Icon(
                  Icons.close,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
