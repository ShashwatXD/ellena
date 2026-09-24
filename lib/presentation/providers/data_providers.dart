import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/api_repository.dart';
import '../../data/api/api_service.dart';
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

final useFakeStreamProvider = Provider<bool>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.enableFakeStream || !config.hasGeminiKey;
});

final streamingServiceProvider = Provider<StreamingService>((ref) {
  if (!ref.watch(useFakeStreamProvider)) {
    final config = ref.watch(appConfigProvider);
    return GeminiStreamingService(
      repository: ref.watch(apiRepositoryProvider),
      apiKey: config.geminiApiKey,
    );
  }
  return FakeStreamingService(
    scenarioOf: () => ref.read(mockStreamScenarioProvider),
  );
});
