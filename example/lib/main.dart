import 'dart:async';
import 'dart:developer';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nfc/ndef_tag.dart';
import 'package:flutter_nfc/nfc.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NdefTag _tag;
  bool _reading = false;

  Future<void> readSingleTag() async {
    setState(() {
      _reading = true;
    });
    NdefTag tag;
    try {
      tag = await Nfc.readTag();
    } on PlatformException catch (e, stacktrace) {
      log("Platform error", error: e, stackTrace: stacktrace);
    }
    await HapticFeedback.vibrate();
    setState(() {
      _reading = false;
      _tag = tag;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
            actions: <Widget>[
              IconButton(
                onPressed: readSingleTag,
                icon: Icon(Icons.call_to_action),
              )
            ],
          ),
          body: _body()),
    );
  }

  Widget _body() {
    if (_reading) {
      return Center(child: Text("Reading"));
    } else {
      return _createList();
    }
  }

  ListView _createList() {
    return ListView(
        shrinkWrap: true,
        children: <Widget>[
          ListTile(
            title: Text('${_tag == null ? "No tag read" : hex.encode(_tag.id)}'),
          )
        ]..addAll(_createDataTiles()));
  }

  List<Widget> _createDataTiles() {
    return _tag != null
        ? _tag.records
            .map((d) => ListTile(
                  title: Text("${d.tnf} ${hex.encode(d.type)}"),
                  subtitle: Text(_getData(d)),
                ))
            .toList()
        : [];
  }

  String _getData(NdefRecord record) {
    if (record is TextNdefRecord) {
      return record.data;
    } else if (record is UriNdefRecord) {
      return record.uri;
    } else if (record is ExternalNdefRecord) {
      return "${record.qualifiedName} ${record.qualifiedType} ${record.data}";
    }
    return "";
  }

  void _init() async {
    await Nfc.startReading();
  }
}
