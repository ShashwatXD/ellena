import '../storage/storage_keys.dart';
import '../storage/storage_service.dart';
import 'history_op.dart';

class HistoryQueue {
  HistoryQueue({StorageService? storage})
      : _storage = storage ?? StorageService.instance;

  final StorageService _storage;

  List<HistoryOp> read() {
    final raw = _storage.get<dynamic>(StorageKeys.historyOps);
    if (raw is! List) return const [];
    final ops = <HistoryOp>[
      for (final item in raw)
        if (item is Map) HistoryOp.fromJson(item),
    ];
    ops.sort((a, b) => a.order.compareTo(b.order));
    return ops;
  }

  Set<String> chatIds() => {for (final op in read()) op.chatId};

  Future<void> add(HistoryOp op) {
    return _write([...read(), op]);
  }

  Future<void> ack(String id) {
    return _write(read().where((op) => op.id != id).toList());
  }

  Future<void> clear() => _storage.delete(StorageKeys.historyOps);

  Future<void> _write(List<HistoryOp> ops) {
    return _storage.set(
      StorageKeys.historyOps,
      ops.map((op) => op.toJson()).toList(),
    );
  }
}
