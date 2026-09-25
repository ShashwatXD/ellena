import 'package:ellena/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('success carries the value', () {
    const result = Success<int>(7);

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull, 7);
    expect(result.errorOrNull, isNull);
    expect(result.when(success: (value) => value, failure: (error, _) => 0), 7);
  });

  test('failure carries the error and no value', () {
    final result = Failure<int>(StateError('nope'));

    expect(result.isFailure, isTrue);
    expect(result.valueOrNull, isNull);
    expect(result.errorOrNull, isA<StateError>());
    expect(
      result.when(success: (value) => 'ok', failure: (error, _) => 'bad'),
      'bad',
    );
  });
}
