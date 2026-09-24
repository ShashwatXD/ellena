import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ellena/app.dart';
import 'package:ellena/storage/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await StorageService.instance.initForTest('.dart_tool/test_hive');
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: EllenaApp(),
      ),
    );
    expect(find.text('Ellena'), findsOneWidget);
  });
}
