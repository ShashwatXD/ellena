import 'storage_keys.dart';
import 'storage_service.dart';

abstract final class AppStorage {
  static Future<void> save(
    String key,
    Object? value, {
    String boxName = StorageKeys.appBox,
  }) {
    return StorageService.instance.set(key, value, boxName: boxName);
  }

  static T? read<T>(
    String key, {
    T? defaultValue,
    String boxName = StorageKeys.appBox,
  }) {
    return StorageService.instance.get<T>(
      key,
      defaultValue: defaultValue,
      boxName: boxName,
    );
  }

  static Future<void> remove(
    String key, {
    String boxName = StorageKeys.appBox,
  }) {
    return StorageService.instance.delete(key, boxName: boxName);
  }

  static bool has(String key, {String boxName = StorageKeys.appBox}) {
    return StorageService.instance.contains(key, boxName: boxName);
  }
}
