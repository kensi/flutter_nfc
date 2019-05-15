import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> readSingleTag() async {
    setState(() {
      _reading = true;
    });
    NdefTag tag;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      tag = await Nfc.readSingleTag;
    } on PlatformException {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _reading = false;
      _tag = tag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: _body(),
        ),
      ),
    );
  }

  List<Widget> _body() {
    if (_reading) {
      return <Widget>[Center(child: Text("Reading"))];
    } else {
      return <Widget>[
        Center(
          child: Text('Read tag: ${_tag == null ? "no tag read" : _tag.records}\n'),
        ),
        RaisedButton(
          child: Text("Read"),
          onPressed: () => readSingleTag(),
        )
      ];
    }
  }
}
