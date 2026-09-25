import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ellena/app.dart';
import 'package:ellena/core/config/app_config.dart';
import 'package:ellena/data/storage/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AppConfig.load();
    await StorageService.instance.initForTest('.dart_tool/test_hive');
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: EllenaApp(),
      ),
    );
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Agent'), findsOneWidget);
    expect(find.text('What can I do for you?'), findsOneWidget);
  });
}
