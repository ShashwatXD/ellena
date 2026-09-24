import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/llm_model.dart';
import '../providers/providers.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

class ModelSelector extends ConsumerWidget {
  const ModelSelector({
    super.key,
    this.enabled = true,
  });

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = ref.watch(selectedModelProvider);

    return PopupMenuButton<LlmModel>(
      tooltip: AppConstants.modelTooltip,
      enabled: enabled,
      offset: const Offset(0, -8),
      position: PopupMenuPosition.over,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: BorderSide(color: colors.outline.withValues(alpha: 0.7)),
      ),
      color: colors.surface,
      elevation: 6,
      shadowColor: colors.shadow.withValues(alpha: 0.18),
      onSelected: (model) {
        HapticFeedback.selectionClick();
        ref.read(selectedModelProvider.notifier).select(model);
      },
      itemBuilder: (context) {
        return [
          for (final model in GeminiModels.all)
            PopupMenuItem<LlmModel>(
              value: model,
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          model.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: model.id == selected.id
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        if (model.subtitle != null)
                          Text(
                            model.subtitle!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (model.id == selected.id)
                    Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: colors.onSurface,
                    ),
                ],
              ),
            ),
        ];
      },
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          height: 36,
          padding: const EdgeInsets.only(left: 10, right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: colors.outline.withValues(alpha: 0.7),
              width: AppSpacing.stroke,
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  selected.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
