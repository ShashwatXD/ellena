import 'dart:async';

import 'package:ellena/core/config/app_config.dart';
import 'package:ellena/core/constants/app_constants.dart';
import 'package:ellena/core/models/chat_attachment.dart';
import 'package:ellena/core/models/conversation.dart';
import 'package:ellena/core/models/message.dart';
import 'package:ellena/core/models/message_status.dart';
import 'package:ellena/data/network/api_exception.dart';
import 'package:ellena/data/storage/chat_storage.dart';
import 'package:ellena/data/storage/storage_service.dart';
import 'package:ellena/data/streaming/stream_event.dart';
import 'package:ellena/data/streaming/streaming_service.dart';
import 'package:ellena/presentation/providers/chat_provider.dart';
import 'package:ellena/presentation/providers/mock_stream_provider.dart';
import 'package:ellena/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _ScriptedService scripted;

  setUpAll(() async {
    await AppConfig.load();
    await StorageService.instance.initForTest('.dart_tool/test_hive_chat_flow');
  });

  setUp(() {
    scripted = _ScriptedService();
  });

  ProviderContainer container() {
    final scope = ProviderContainer(
      overrides: [
        streamingServiceProvider.overrideWithValue(scripted),
        useFakeStreamProvider.overrideWith(_AlwaysMock.new),
      ],
    );
    addTearDown(scope.dispose);
    return scope;
  }

  Message assistant(ProviderContainer scope, String conversationId) {
    return scope
        .read(chatProvider)
        .messagesFor(conversationId)
        .lastWhere((message) => message.role == MessageRole.assistant);
  }

  test('stop keeps partial text and drops a later token', () async {
    final scope = container();
    final notifier = scope.read(chatProvider.notifier);
    final id = notifier.startConversation('hello');
    await pumpEventQueue();

    scripted.emit(const StreamEvent.text(generation: 1, seq: 1, text: 'Hello'));
    await pumpEventQueue();

    await notifier.stopStreaming(id);
    scripted.emit(const StreamEvent.text(generation: 1, seq: 2, text: ' more'));
    await pumpEventQueue();

    final reply = assistant(scope, id);
    expect(reply.content, 'Hello');
    expect(reply.status, MessageStatus.stopped);
    expect(scripted.starts, 1);
  });

  test('retry runs only when the user asks', () async {
    final scope = container();
    final notifier = scope.read(chatProvider.notifier);
    final id = notifier.startConversation('hello');
    await pumpEventQueue();

    scripted.fail(const ApiException(message: AppConstants.connectionFailed));
    await pumpEventQueue();

    expect(assistant(scope, id).status, MessageStatus.failed);
    expect(scripted.starts, 1);

    final messageId = assistant(scope, id).id;
    notifier.retryMessage(id, messageId);
    await pumpEventQueue();

    expect(scripted.starts, 2);
    expect(assistant(scope, id).status, MessageStatus.streaming);
  });

  test('force-kill reload does not leave a message streaming', () async {
    final storage = ChatStorage();
    const conversationId = 'kill_chat';
    final now = DateTime.utc(2026, 9, 25);

    await storage.saveConversation(
      Conversation(id: conversationId, title: 'Kill', updatedAt: now),
    );
    await storage.saveMessages(conversationId, [
      Message(
        id: 'user',
        conversationId: conversationId,
        role: MessageRole.user,
        content: 'hi',
        status: MessageStatus.complete,
        createdAt: now,
      ),
      Message(
        id: 'partial',
        conversationId: conversationId,
        role: MessageRole.assistant,
        content: 'Hel',
        status: MessageStatus.streaming,
        createdAt: now,
      ),
      Message(
        id: 'empty',
        conversationId: conversationId,
        role: MessageRole.assistant,
        content: '',
        status: MessageStatus.streaming,
        createdAt: now,
      ),
    ]);

    final snapshot = storage.load().valueOrNull!;
    final messages = snapshot.messagesByConversation[conversationId]!;

    expect(messages[1].status, MessageStatus.stopped);
    expect(messages[1].content, 'Hel');
    expect(messages[2].status, MessageStatus.failed);
    expect(messages[2].error, 'Interrupted');
  });
}

class _AlwaysMock extends UseFakeStreamNotifier {
  @override
  bool build() => true;
}

class _ScriptedService implements StreamingService {
  int starts = 0;
  int _generation = 0;
  StreamController<StreamEvent>? _active;

  @override
  int beginGeneration() => ++_generation;

  @override
  Stream<StreamEvent> streamReply({
    required String prompt,
    required String model,
    List<ChatTurn> history = const [],
    String? systemInstruction,
    ChatAttachment? attachment,
  }) {
    starts++;
    final controller = StreamController<StreamEvent>();
    _active = controller;
    return controller.stream;
  }

  void emit(StreamEvent event) {
    _active?.add(event);
  }

  void fail(Object error) {
    _active?.addError(error);
  }

  @override
  Future<void> cancel() async {
    _generation++;
  }
}
