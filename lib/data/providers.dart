import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config_provider.dart';
import 'api/api_repository.dart';
import 'api/api_service.dart';
import 'storage/storage_service.dart';

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
