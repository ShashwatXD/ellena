import 'package:ellena/core/utils/uuid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v4 has the standard shape', () {
    final id = Uuid.v4();
    expect(
      RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ).hasMatch(id),
      isTrue,
    );
    expect(Uuid.v4(), isNot(id));
  });
}
