import '../../core/utils/uuid.dart';
import 'app_storage.dart';
import 'storage_keys.dart';

abstract final class InstallId {
  static String? read() {
    final stored = AppStorage.read<String>(StorageKeys.installId);
    if (stored == null || stored.isEmpty) return null;
    return stored;
  }

  static Future<String> ensure() async {
    final stored = read();
    if (stored != null) return stored;
    final created = Uuid.v4();
    await AppStorage.save(StorageKeys.installId, created);
    return created;
  }
}
