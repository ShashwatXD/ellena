import 'package:ellena/app.dart';
import 'package:ellena/core/config/app_config.dart';
import 'package:ellena/data/storage/app_storage.dart';
import 'package:ellena/data/storage/storage_keys.dart';
import 'package:ellena/data/storage/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AppConfig.load();
    await StorageService.instance.initForTest('.dart_tool/test_hive_smoke');
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await AppStorage.save(StorageKeys.signedIn, true).timeout(
      const Duration(seconds: 5),
    );
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
