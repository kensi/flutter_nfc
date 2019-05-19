import 'package:flutter/services.dart';
import 'package:flutter_nfc/nfc.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  const MethodChannel channel = MethodChannel('neonchipmunk.com/nfc');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('readSingleTag', () async {
    expect(await Nfc.readTag(), '42');
  });
}
