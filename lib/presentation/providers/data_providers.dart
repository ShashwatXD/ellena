import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/api_repository.dart';
import '../../data/api/api_service.dart';
import '../../data/storage/storage_keys.dart';
import '../../data/storage/storage_service.dart';
import '../../data/streaming/fake_streaming_service.dart';
import '../../data/streaming/gemini_streaming_service.dart';
import '../../data/streaming/streaming_service.dart';
import 'app_config_provider.dart';
import 'mock_stream_scenario_provider.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final config = ref.watch(appConfigProvider);
  return ApiService(baseUrl: config.apiBaseUrl);
});

final apiRepositoryProvider = Provider<ApiRepository>((ref) {
  return ApiRepository(ref.watch(apiServiceProvider));
});

/// Dev-only. Persisted so hot reload doesn't flip mock back on.
final useFakeStreamProvider =
    NotifierProvider<UseFakeStreamNotifier, bool>(UseFakeStreamNotifier.new);

class UseFakeStreamNotifier extends Notifier<bool> {
  @override
  bool build() {
    final config = ref.read(appConfigProvider);
    if (!config.isDev) return false;
    return StorageService.instance.get<bool>(StorageKeys.mockStreamEnabled) ??
        true;
  }

  Future<void> setEnabled(bool enabled) async {
    if (!ref.read(appConfigProvider).isDev) return;
    await StorageService.instance.set(StorageKeys.mockStreamEnabled, enabled);
    state = enabled;
  }
}

final fakeStreamingProvider = Provider<FakeStreamingService>((ref) {
  return FakeStreamingService(
    scenarioOf: () => ref.read(mockStreamScenarioProvider),
  );
});

final geminiStreamingProvider = Provider<GeminiStreamingService>((ref) {
  final config = ref.watch(appConfigProvider);
  return GeminiStreamingService(
    repository: ref.watch(apiRepositoryProvider),
    apiKey: config.geminiApiKey,
  );
});

/// Prefer [fakeStreamingProvider] / [geminiStreamingProvider] via chat notifier.
final streamingServiceProvider = Provider<StreamingService>((ref) {
  if (ref.watch(useFakeStreamProvider)) {
    return ref.watch(fakeStreamingProvider);
  }
  return ref.watch(geminiStreamingProvider);
});
