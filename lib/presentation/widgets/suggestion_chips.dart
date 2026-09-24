import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_breakpoints.dart';
import '../theme/app_motion.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

class SuggestionChips extends StatelessWidget {
  const SuggestionChips({
    super.key,
    required this.suggestions,
    required this.onSelected,
    this.selectedLabel,
  });

  final List<({IconData icon, String label})> suggestions;
  final ValueChanged<String> onSelected;
  final String? selectedLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppBreakpoints.pagePadding(context),
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < suggestions.length; i++)
            _SuggestionChip(
              index: i,
              icon: suggestions[i].icon,
              label: suggestions[i].label,
              selected: selectedLabel == suggestions[i].label,
              onSelected: () => onSelected(suggestions[i].label),
            ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatefulWidget {
  const _SuggestionChip({
    required this.index,
    required this.icon,
    required this.label,
    required this.onSelected,
    this.selected = false,
  });

  final int index;
  final IconData icon;
  final String label;
  final VoidCallback onSelected;
  final bool selected;

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: AppMotion.emphasis,
    );
    Future<void>.delayed(Duration(milliseconds: 40 * widget.index), () {
      if (mounted) _enter.forward();
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final motion = AppMotion.of(context, AppMotion.fast);
    final reduce = MediaQuery.disableAnimationsOf(context);
    final selected = widget.selected;

    final chip = AnimatedScale(
      scale: _pressed ? 0.96 : 1,
      duration: motion,
      curve: AppMotion.standard,
      child: Material(
        color: selected
            ? colors.onSurface.withValues(alpha: 0.08)
            : colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          side: BorderSide(
            color: selected
                ? colors.onSurface.withValues(alpha: 0.45)
                : colors.outline,
            width: selected ? 1.25 : AppSpacing.stroke,
          ),
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
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (reduce) return chip;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _enter, curve: AppMotion.standard),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _enter, curve: AppMotion.standard)),
        child: chip,
      ),
    );
  }
}
