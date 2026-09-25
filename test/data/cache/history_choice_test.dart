import 'package:ellena/core/models/conversation.dart';
import 'package:ellena/data/cache/history_choice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final earlier = DateTime.utc(2026, 9, 26, 8);
  final later = earlier.add(const Duration(minutes: 5));

  Conversation chat(String title, DateTime updatedAt) {
    return Conversation(id: 'c1', title: title, updatedAt: updatedAt);
  }

  test('the later remote copy is the history', () {
    final chosen = preferLater(
      local: chat('Local title', earlier),
      remote: chat('Server title', later),
    );
    expect(chosen.title, 'Server title');
  });

  test('the later local copy stays', () {
    final chosen = preferLater(
      local: chat('Local title', later),
      remote: chat('Server title', earlier),
    );
    expect(chosen.title, 'Local title');
  });

  test('equal times keep the local copy', () {
    final chosen = preferLater(
      local: chat('Local title', earlier),
      remote: chat('Server title', earlier),
    );
    expect(chosen.title, 'Local title');
  });
}
