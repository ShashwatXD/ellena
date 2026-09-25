import 'package:ellena/core/config/app_config.dart';
import 'package:ellena/core/models/conversation.dart';
import 'package:ellena/core/models/message.dart';
import 'package:ellena/core/models/message_status.dart';
import 'package:ellena/data/storage/chat_storage.dart';
import 'package:ellena/data/storage/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ChatStorage storage;

  setUpAll(() async {
    await AppConfig.load();
    await StorageService.instance.initForTest('.dart_tool/test_hive_storage');
    storage = ChatStorage();
  });

  setUp(() async {
    await storage.clear();
  });

  Conversation chat(String id, DateTime updatedAt, {bool pinned = false}) {
    return Conversation(
      id: id,
      title: id,
      updatedAt: updatedAt,
      isPinned: pinned,
    );
  }

  test('load sorts conversations newest first and round-trips messages', () async {
    final older = DateTime.utc(2026, 9, 24);
    final newer = DateTime.utc(2026, 9, 25);
    await storage.saveConversation(chat('old', older));
    await storage.saveConversation(chat('new', newer, pinned: true));
    await storage.saveMessages('new', [
      Message(
        id: 'm1',
        conversationId: 'new',
        role: MessageRole.user,
        content: 'hi',
        status: MessageStatus.complete,
        createdAt: newer,
      ),
    ]);

    final snapshot = storage.load().valueOrNull!;

    expect(snapshot.conversations.map((item) => item.id), ['new', 'old']);
    expect(snapshot.conversations.first.isPinned, isTrue);
    expect(snapshot.messagesByConversation['new']!.single.content, 'hi');
    expect(snapshot.messagesByConversation['old'], isEmpty);
  });

  test('delete removes the conversation and its messages', () async {
    final now = DateTime.utc(2026, 9, 25);
    await storage.saveConversation(chat('a', now));
    await storage.saveMessages('a', [
      Message(
        id: 'm1',
        conversationId: 'a',
        role: MessageRole.user,
        content: 'hi',
        status: MessageStatus.complete,
        createdAt: now,
      ),
    ]);

    await storage.deleteConversation('a');

    expect(storage.readConversation('a'), isNull);
    expect(storage.hasMessages('a'), isFalse);
  });
}
