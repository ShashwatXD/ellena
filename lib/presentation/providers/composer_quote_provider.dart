import 'package:flutter_riverpod/flutter_riverpod.dart';

final composerQuoteProvider =
    NotifierProvider<ComposerQuoteNotifier, String?>(ComposerQuoteNotifier.new);

class ComposerQuoteNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String text) {
    final trimmed = text.trim();
    state = trimmed.isEmpty ? null : trimmed;
  }

  void clear() => state = null;
}
