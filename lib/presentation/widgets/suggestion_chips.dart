import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        alignment: WrapAlignment.center,
        children: [
          for (final suggestion in suggestions)
            _SuggestionChip(
              icon: suggestion.icon,
              label: suggestion.label,
              onSelected: () => onSelected(suggestion.label),
            ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatefulWidget {
  const _SuggestionChip({
    required this.icon,
    required this.label,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final VoidCallback onSelected;

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Material(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          side: BorderSide(color: colors.outline, width: AppSpacing.stroke),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onSelected();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 16,
                  color: colors.onSurface.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
