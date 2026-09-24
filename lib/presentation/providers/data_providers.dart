import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/api_repository.dart';
import '../../data/api/api_service.dart';
import '../../data/storage/chat_storage.dart';
import '../../data/storage/storage_service.dart';
import '../../data/streaming/gemini_streaming_service.dart';
import '../../data/streaming/gemini_title_service.dart';
import '../../data/streaming/streaming_service.dart';
import 'app_config_provider.dart';
import 'mock_stream_provider.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

final chatStorageProvider = Provider<ChatStorage>((ref) {
  return ChatStorage(storage: ref.watch(storageServiceProvider));
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final config = ref.watch(appConfigProvider);
  return ApiService(baseUrl: config.apiBaseUrl);
});

final apiRepositoryProvider = Provider<ApiRepository>((ref) {
  return ApiRepository(ref.watch(apiServiceProvider));
});

final geminiStreamingProvider = Provider<GeminiStreamingService>((ref) {
  final config = ref.watch(appConfigProvider);
  return GeminiStreamingService(
    repository: ref.watch(apiRepositoryProvider),
    apiKey: config.geminiApiKey,
  );
});

final geminiTitleProvider = Provider<GeminiTitleService>((ref) {
  final config = ref.watch(appConfigProvider);
  return GeminiTitleService(
    repository: ref.watch(apiRepositoryProvider),
    apiKey: config.geminiApiKey,
  );
});

/// One switch for the app: mock file owns fake; here we pick active service.
final streamingServiceProvider = Provider<StreamingService>((ref) {
  if (ref.watch(useFakeStreamProvider)) {
    return ref.watch(fakeStreamingProvider);
  }
  return ref.watch(geminiStreamingProvider);
});
