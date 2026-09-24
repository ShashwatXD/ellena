import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/mock_stream_scenario.dart';
import '../providers/providers.dart';
import '../theme/app_breakpoints.dart';
import '../theme/app_motion.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

/// Dev + fake-stream only. Replaces home suggestion chips.
class MockScenarioPicker extends ConsumerWidget {
  const MockScenarioPicker({
    super.key,
    required this.onSelected,
  });

  final ValueChanged<MockStreamScenario> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final useFake = ref.watch(useFakeStreamProvider);
    if (!config.isDev || !useFake) return const SizedBox.shrink();

    final selected = ref.watch(mockStreamScenarioProvider);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppBreakpoints.pagePadding(context),
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < MockStreamScenario.all.length; i++)
            _ScenarioChip(
              index: i,
              scenario: MockStreamScenario.all[i],
              selected: MockStreamScenario.all[i] == selected,
              onSelected: () {
                final scenario = MockStreamScenario.all[i];
                ref.read(mockStreamScenarioProvider.notifier).select(scenario);
                onSelected(scenario);
              },
            ),
        ],
      ),
    );
  }
}

class _ScenarioChip extends StatefulWidget {
  const _ScenarioChip({
    required this.index,
    required this.scenario,
    required this.selected,
    required this.onSelected,
  });

  final int index;
  final MockStreamScenario scenario;
  final bool selected;
  final VoidCallback onSelected;

  @override
  State<_ScenarioChip> createState() => _ScenarioChipState();
}

class _ScenarioChipState extends State<_ScenarioChip>
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
                  widget.scenario.icon,
                  size: 16,
                  color: colors.onSurface.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.scenario.label,
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
