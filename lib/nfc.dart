import 'dart:async';
import 'package:flutter/services.dart';

import 'ndef_tag.dart';


class Nfc {

  static const MethodChannel _channel = const MethodChannel('neonchipmunk.com/nfc', JSONMethodCodec());

  static Future<NdefTag> readTag() async {
    Map<String, dynamic> t = await _channel.invokeMethod('readTag');
    return NdefTag.fromJson(t);
  }
}
