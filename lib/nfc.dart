import 'dart:async';

import 'package:flutter/services.dart';

import 'ndef_tag.dart';


class Nfc {
  static const MethodChannel _channel = const MethodChannel('neonchipmunk.com/nfc', JSONMethodCodec());

  static Future<NdefTag> get readSingleTag async {
    Map<String, dynamic> t = await _channel.invokeMethod('readSingleTag');

    return NdefTag.fromJson(t);
  }
}
