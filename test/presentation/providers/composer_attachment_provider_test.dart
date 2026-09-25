import 'package:ellena/core/models/chat_attachment.dart';
import 'package:ellena/presentation/providers/composer_attachment_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('set keeps the file and clear drops it', () {
    final scope = ProviderContainer();
    addTearDown(scope.dispose);

    const file = ChatAttachment(
      name: 'notes.pdf',
      mimeType: 'application/pdf',
      path: '/tmp/notes.pdf',
      sizeBytes: 12,
    );

    scope.read(composerAttachmentProvider.notifier).set(file);
    expect(scope.read(composerAttachmentProvider)?.name, 'notes.pdf');

    scope.read(composerAttachmentProvider.notifier).clear();
    expect(scope.read(composerAttachmentProvider), isNull);
  });
}
