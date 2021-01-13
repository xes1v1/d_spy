import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d_spy/stack_spy/spy.dart';

void main() {
  const MethodChannel channel = MethodChannel('d_spy');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await DSpy.platformVersion, '42');
  });
}
