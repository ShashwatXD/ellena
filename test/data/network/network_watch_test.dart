import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ellena/data/network/api_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wifi or mobile is online', () {
    expect(hasNetwork([ConnectivityResult.wifi]), isTrue);
    expect(hasNetwork([ConnectivityResult.mobile]), isTrue);
    expect(hasNetwork([ConnectivityResult.none, ConnectivityResult.wifi]), isTrue);
  });

  test('none is offline', () {
    expect(hasNetwork([ConnectivityResult.none]), isFalse);
    expect(hasNetwork(const []), isFalse);
  });
}
