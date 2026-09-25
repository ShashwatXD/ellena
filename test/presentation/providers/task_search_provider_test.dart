import 'package:ellena/presentation/providers/task_search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('closing search clears the query', () {
    final scope = ProviderContainer();
    addTearDown(scope.dispose);
    final search = scope.read(taskSearchProvider.notifier);

    search.open();
    search.setQuery('notes');
    expect(scope.read(taskSearchProvider).open, isTrue);
    expect(scope.read(taskSearchProvider).query, 'notes');

    search.close();
    expect(scope.read(taskSearchProvider).open, isFalse);
    expect(scope.read(taskSearchProvider).query, isEmpty);
  });
}
