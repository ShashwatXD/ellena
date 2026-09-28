import 'package:ellena/presentation/utils/markdown_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an open fence is balanced for display and a closed fence is left alone', () {
    const open = '```dart\nfinal name = 1;\n';
    expect(visibleMarkdown(open), '```dart\nfinal name = 1;\n```\n');

    const closed = '```dart\nfinal name = 1;\n```\n';
    expect(visibleMarkdown(closed), closed);

    const prose = 'No fence here.';
    expect(visibleMarkdown(prose), prose);
  });
}
