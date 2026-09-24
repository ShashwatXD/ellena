import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/mock_stream_scenario.dart';

final mockStreamScenarioProvider =
    NotifierProvider<MockStreamScenarioNotifier, MockStreamScenario>(
  MockStreamScenarioNotifier.new,
);

class MockStreamScenarioNotifier extends Notifier<MockStreamScenario> {
  @override
  MockStreamScenario build() => MockStreamScenario.markdown;

  void select(MockStreamScenario scenario) => state = scenario;
}
