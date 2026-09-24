import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'storage_keys.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  bool _ready = false;
  final Set<String> _openBoxes = {};

  bool get isReady => _ready;

  Future<void> init() async {
    if (_ready) return;
    await Hive.initFlutter();
    await openBox(StorageKeys.appBox);
    _ready = true;
  }

  @visibleForTesting
  Future<void> initForTest(String path) async {
    if (_ready) return;
    Hive.init(path);
    await openBox(StorageKeys.appBox);
    _ready = true;
  }

  Future<Box<dynamic>> openBox(String name) async {
    if (Hive.isBoxOpen(name)) {
      _openBoxes.add(name);
      return Hive.box<dynamic>(name);
    }
    final opened = await Hive.openBox<dynamic>(name);
    _openBoxes.add(name);
    return opened;
  }

  Box<dynamic> box([String name = StorageKeys.appBox]) {
    _ensureReady();
    return Hive.box<dynamic>(name);
  }

  T? get<T>(String key, {String boxName = StorageKeys.appBox, T? defaultValue}) {
    final value = box(boxName).get(key, defaultValue: defaultValue);
    if (value == null) return defaultValue;
    return value as T?;
  }

  Future<void> set<T>(
    String key,
    T value, {
    String boxName = StorageKeys.appBox,
  }) {
    return box(boxName).put(key, value);
  }

  Future<void> delete(String key, {String boxName = StorageKeys.appBox}) {
    return box(boxName).delete(key);
  }

  bool contains(String key, {String boxName = StorageKeys.appBox}) {
    return box(boxName).containsKey(key);
  }

  Future<void> clear([String boxName = StorageKeys.appBox]) {
    return box(boxName).clear();
  }

  Future<void> clearAll() async {
    _ensureReady();
    for (final name in _openBoxes) {
      if (Hive.isBoxOpen(name)) {
        await Hive.box<dynamic>(name).clear();
      }
    }
  }

  int length({String boxName = StorageKeys.appBox}) => box(boxName).length;

  Iterable<dynamic> keys({String boxName = StorageKeys.appBox}) {
    return box(boxName).keys;
  }

  void _ensureReady() {
    assert(_ready, 'StorageService.init() must be called before use');
  }
}
