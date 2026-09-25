import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/models/mock_stream_scenario.dart';
import '../../data/streaming/fake_streaming_service.dart';
import 'app_config_provider.dart';

/// Single home for mock stream: availability, toggle, scenario, fake service.
final mockControlsAvailableProvider = Provider<bool>((ref) {
  ref.watch(appConfigProvider);
  return AppConfig.isDev;
});

final useFakeStreamProvider =
    NotifierProvider<UseFakeStreamNotifier, bool>(UseFakeStreamNotifier.new);

class UseFakeStreamNotifier extends Notifier<bool> {
  @override
  bool build() {
    if (!ref.read(mockControlsAvailableProvider)) return false;
    return ref.read(appConfigProvider).enableFakeStream;
  }

  void setEnabled(bool enabled) {
    if (!ref.read(mockControlsAvailableProvider)) return;
    state = enabled;
  }
}

final mockStreamScenarioProvider =
    NotifierProvider<MockStreamScenarioNotifier, MockStreamScenario>(
  MockStreamScenarioNotifier.new,
);

class MockStreamScenarioNotifier extends Notifier<MockStreamScenario> {
  @override
  MockStreamScenario build() => MockStreamScenario.markdown;

  void select(MockStreamScenario scenario) => state = scenario;
}

final fakeStreamingProvider = Provider<FakeStreamingService>((ref) {
  return FakeStreamingService(
    scenarioOf: () => ref.read(mockStreamScenarioProvider),
  );
});
