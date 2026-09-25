import 'package:ellena/data/history/history_op.dart';
import 'package:ellena/data/history/history_queue.dart';
import 'package:ellena/data/storage/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HistoryQueue queue;

  setUpAll(() async {
    await StorageService.instance.initForTest('.dart_tool/test_hive_history_ops');
    queue = HistoryQueue();
  });

  setUp(() async {
    await queue.clear();
  });

  HistoryOp op(String id, String chatId, String kind, int order) {
    return HistoryOp(
      id: id,
      chatId: chatId,
      kind: kind,
      order: order,
      body: kind == HistoryOpKind.delete ? null : {'title': kind},
    );
  }

  test('keeps six operations in order and drops an id once', () async {
    final saved = [
      op('op-1', 'a', HistoryOpKind.rename, 1),
      op('op-2', 'b', HistoryOpKind.rename, 2),
      op('op-3', 'c', HistoryOpKind.rename, 3),
      op('op-4', 'd', HistoryOpKind.delete, 4),
      op('op-5', 'e', HistoryOpKind.pin, 5),
      op('op-6', 'f', HistoryOpKind.send, 6),
    ];
    for (final item in saved) {
      await queue.add(item);
    }

    expect(queue.read().map((item) => item.id).toList(), [
      'op-1',
      'op-2',
      'op-3',
      'op-4',
      'op-5',
      'op-6',
    ]);
    expect(queue.read().map((item) => item.kind).toList(), [
      HistoryOpKind.rename,
      HistoryOpKind.rename,
      HistoryOpKind.rename,
      HistoryOpKind.delete,
      HistoryOpKind.pin,
      HistoryOpKind.send,
    ]);

    await queue.ack('op-1');
    await queue.ack('op-1');

    final left = queue.read();
    expect(left.map((item) => item.id).toList(), [
      'op-2',
      'op-3',
      'op-4',
      'op-5',
      'op-6',
    ]);
    expect(left.first.kind, HistoryOpKind.rename);
    expect(left[2].kind, HistoryOpKind.delete);
    expect(left[2].body, isNull);
  });
}
