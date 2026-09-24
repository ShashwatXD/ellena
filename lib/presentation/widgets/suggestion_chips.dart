import 'package:flutter/material.dart';

import '../theme/app_radii.dart';

class SuggestionChips extends StatelessWidget {
  const SuggestionChips({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  final List<({IconData icon, String label})> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final suggestion in suggestions)
          Material(
            color: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              side: BorderSide(color: colors.outline),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              onTap: () => onSelected(suggestion.label),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      suggestion.icon,
                      size: 16,
                      color: colors.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      suggestion.label,
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
