import 'package:ellena/core/config/app_config.dart';
import 'package:ellena/core/models/conversation.dart';
import 'package:ellena/core/models/message.dart';
import 'package:ellena/core/models/message_status.dart';
import 'package:ellena/core/result/result.dart';
import 'package:ellena/data/cache/chat_cache.dart';
import 'package:ellena/data/cache/chat_remote.dart';
import 'package:ellena/data/storage/chat_storage.dart';
import 'package:ellena/data/storage/storage_service.dart';
import 'package:ellena/presentation/providers/chat_provider.dart';
import 'package:ellena/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ChatStorage storage;

  setUpAll(() async {
    await AppConfig.load();
    await StorageService.instance.initForTest(
      '.dart_tool/test_hive_chat_cache',
    );
    storage = ChatStorage();
  });

  setUp(() async {
    await storage.clear();
  });

  Conversation chat(String id, String title, DateTime updatedAt) {
    return Conversation(id: id, title: title, updatedAt: updatedAt);
  }

  test('list stays stale until the parent collection is invalidated', () async {
    final older = DateTime.utc(2026, 9, 25);
    final newer = older.add(const Duration(minutes: 1));
    await storage.saveConversation(chat('a', 'Old', older));

    final cache = ChatCache(
      storage: storage,
      remote: const UnavailableChatRemote(),
    );
    expect(cache.readConversations().single.title, 'Old');

    await storage.saveConversation(chat('a', 'New', newer));
    cache.invalidateRecord('a');
    expect(cache.readConversations().single.title, 'Old');

    cache.invalidateList();
    expect(cache.readConversations().single.title, 'New');
  });

  test('message windows keep the open chat and a protected stream', () async {
    final now = DateTime.utc(2026, 9, 25);
    await storage.saveConversation(chat('a', 'A', now));
    await storage.saveConversation(chat('b', 'B', now));
    await storage.saveMessages('a', [_message('a', 'm1')]);
    await storage.saveMessages('b', [_message('b', 'm2')]);

    final cache = ChatCache(
      storage: storage,
      remote: const UnavailableChatRemote(),
    );
    cache.protect('a');
    cache.readMessages('a');
    cache.readMessages('b');

    expect(cache.windows().keys, {'a', 'b'});

    cache.unprotect('a', keep: 'b');
    expect(cache.windows().keys, {'b'});
  });

  test('a local miss reads the remote conversation once', () async {
    final remote = _Remote();
    final cache = ChatCache(storage: storage, remote: remote);
    final now = DateTime.utc(2026, 9, 25);
    remote.conversationRow = chat('remote', 'From server', now);

    expect(cache.readConversation('remote')?.title, 'From server');
    expect(cache.readConversation('remote')?.title, 'From server');
    expect(remote.conversationReads, 1);

    await pumpEventQueue();
    await storage.saveConversation(chat('remote', 'Hive title', now));
    expect(cache.readConversation('remote')?.title, 'From server');

    cache.invalidateRecord('remote');
    expect(cache.readConversation('remote')?.title, 'Hive title');
    expect(remote.conversationReads, 2);
  });

  test('history keeps the copy with the later update', () async {
    final older = DateTime.utc(2026, 9, 25);
    final newer = older.add(const Duration(hours: 2));
    await storage.saveConversation(chat('shared', 'Local title', older));
    final remote = _Remote()..conversationRow = chat('shared', 'Server title', newer);
    final cache = ChatCache(storage: storage, remote: remote);

    expect(cache.readConversation('shared')?.title, 'Server title');

    await pumpEventQueue();
    cache.invalidateRecord('shared');
    expect(storage.readConversation('shared')?.title, 'Server title');
  });

  test('rename invalidates the list the drawer reads', () async {
    final older = DateTime.utc(2026, 9, 25);
    await storage.saveConversation(chat('a', 'Old', older));

    final scope = ProviderContainer();
    addTearDown(scope.dispose);
    scope.read(chatProvider);
    expect(scope.read(chatProvider).conversationById('a')?.title, 'Old');

    scope.read(chatProvider.notifier).renameConversation('a', 'Renamed');
    await pumpEventQueue();

    expect(scope.read(chatProvider).conversationById('a')?.title, 'Renamed');
    expect(
      scope.read(chatCacheProvider).readConversations().single.title,
      'Renamed',
    );
  });
}

Message _message(String conversationId, String id) {
  return Message(
    id: id,
    conversationId: conversationId,
    role: MessageRole.user,
    content: 'hi',
    status: MessageStatus.complete,
    createdAt: DateTime.utc(2026, 9, 25),
  );
}

class _Remote implements ChatRemote {
  Conversation? conversationRow;
  int conversationReads = 0;

  @override
  Result<Conversation?> conversation(String id) {
    conversationReads++;
    return Success(conversationRow);
  }

  @override
  Result<List<Message>?> messages(String conversationId) => const Success(null);
}
