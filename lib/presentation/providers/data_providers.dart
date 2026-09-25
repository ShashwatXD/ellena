import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/network/api_repository.dart';
import '../../data/network/api_service.dart';
import '../../data/cache/chat_cache.dart';
import '../../data/cache/chat_remote.dart';
import '../../data/storage/chat_storage.dart';
import '../../data/history/history_sync.dart';
import '../../data/storage/install_id.dart';
import '../../data/storage/storage_service.dart';
import '../../data/streaming/gemini_streaming_service.dart';
import '../../data/streaming/gemini_title_service.dart';
import '../../data/streaming/streaming_service.dart';
import 'app_config_provider.dart';
import 'mock_stream_provider.dart';

final installIdProvider = Provider<String?>((ref) => InstallId.read());

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

final chatStorageProvider = Provider<ChatStorage>((ref) {
  return ChatStorage(storage: ref.watch(storageServiceProvider));
});

final chatRemoteProvider = Provider<ChatRemote>((ref) {
  return const UnavailableChatRemote();
});

final chatCacheProvider = Provider<ChatCache>((ref) {
  return ChatCache(
    storage: ref.watch(chatStorageProvider),
    remote: ref.watch(chatRemoteProvider),
  );
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final config = ref.watch(appConfigProvider);
  final api = ApiService(
    baseUrl: config.apiBaseUrl,
    apiKey: config.geminiApiKey,
  );
  ref.onDispose(api.dispose);
  return api;
});

final apiRepositoryProvider = Provider<ApiRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  final url = config.reachableHistoryBaseUrl;
  final installId = InstallId.read();
  ApiService? history;
  if (url.isNotEmpty && installId != null) {
    history = ApiService(baseUrl: url, apiKey: '');
    ref.onDispose(history.dispose);
  }
  return ApiRepository(
    ref.watch(apiServiceProvider),
    history: history,
  );
});

final historySyncProvider = Provider<HistorySync>((ref) {
  return HistorySync(
    api: ref.watch(apiRepositoryProvider),
    storage: ref.watch(chatStorageProvider),
  );
});

final geminiStreamingProvider = Provider<GeminiStreamingService>((ref) {
  return GeminiStreamingService(repository: ref.watch(apiRepositoryProvider));
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
