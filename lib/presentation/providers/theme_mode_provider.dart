import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/storage/app_storage.dart';
import '../../data/storage/storage_keys.dart';

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final raw = AppStorage.read<String>(StorageKeys.themeMode);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == raw,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    await AppStorage.save(StorageKeys.themeMode, mode.name);
    state = mode;
  }
}
