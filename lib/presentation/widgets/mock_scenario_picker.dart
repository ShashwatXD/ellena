import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/mock_stream_scenario.dart';
import '../providers/providers.dart';
import 'suggestion_chips.dart';

class MockScenarioPicker extends ConsumerWidget {
  const MockScenarioPicker({
    super.key,
    required this.onSelected,
  });

  final ValueChanged<MockStreamScenario> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SuggestionChips(
      suggestions: [
        for (final scenario in MockStreamScenario.all)
          (icon: scenario.icon, label: scenario.label),
      ],
      onSelected: (label) {
        final scenario = MockStreamScenario.byLabel(label);
        ref.read(mockStreamScenarioProvider.notifier).select(scenario);
        onSelected(scenario);
      },
    );
  }
}
