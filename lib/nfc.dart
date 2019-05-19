import 'dart:async';
import 'package:flutter/services.dart';

import 'ndef_tag.dart';

class Nfc {
  static const MethodChannel _channel = const MethodChannel('neonchipmunk.com/nfc', JSONMethodCodec());
  static const EventChannel _eventChannel = const EventChannel('neonchipmunk.com/nfc/events', JSONMethodCodec());

  static Future<void> startReading() async {
    await _channel.invokeMethod("start");
  }

  static Future<void> stopReading() async {
    await _channel.invokeMethod("stop");
  }

  static Future<NdefTag> readTag() async {
    Map<String, dynamic> t = await _eventChannel.receiveBroadcastStream().first;
    return NdefTag.fromJson(t);
  }
}
