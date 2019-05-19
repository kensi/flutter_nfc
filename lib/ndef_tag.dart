import 'dart:convert';

class NdefTag {
  final List<int> id;
  final List<NdefRecord> records;

  NdefTag(this.id, this.records);

  factory NdefTag.fromJson(Map<String, dynamic> json) {
    var records = json['records'] as List;
    return NdefTag(base64.decode(json['id']), records.map((recordJson) => NdefRecord.fromJson(recordJson)).toList());
  }
}

const int TNF_WELL_KNOWN = 0x01;
const int TNF_EXTERNAL_TYPE = 0x04;

const int TYPE_TEXT = 0x54;
const int TYPE_URI = 0x55;
const List<String> URI_PREFIX_MAP = [
  "",
  "http://www.",
  "https://www.",
  "http://",
  "https://",
  "tel:",
  "mailto:",
  "ftp://anonymous:anonymous@",
  "ftp://ftp.",
  "ftps://",
  "sftp://",
  "smb://",
  "nfs://",
  "ftp://",
  "dav://",
  "news:",
  "telnet://",
  "imap:",
  "rtsp://",
  "urn:",
  "pop:",
  "sip:",
  "sips:",
  "tftp:",
  "btspp://",
  "btl2cap://",
  "btgoep://",
  "tcpobex://",
  "irdaobex://",
  "file://",
  "urn:epc:id:",
  "urn:epc:tag:",
  "urn:epc:pat:",
  "urn:epc:raw:",
  "urn:epc:",
  "urn:nfc:",
];

abstract class NdefRecord {
  final int tnf;
  final List<int> type;
  final List<int> id;
  final List<int> payload;

  NdefRecord(this.tnf, this.type, this.id, this.payload);

  factory NdefRecord.fromJson(Map<String, dynamic> json) {
    int tnf = json['tnf'];
    List<int> type = base64.decode(json['type']);
    List<int> id = base64.decode(json['id']);
    List<int> payload = base64.decode(json['payload']);
    if (tnf == TNF_WELL_KNOWN) {
      if (type[0] == TYPE_TEXT) {
        String data = String.fromCharCodes(payload, payload[0] + 1);
        return TextNdefRecord(tnf, type, id, payload, data);
      } else if (type[0] == TYPE_URI) {
        String uri = URI_PREFIX_MAP[payload[0]] + String.fromCharCodes(payload, 1);
        return UriNdefRecord(tnf, type, id, payload, uri);
      } else {
        throw FormatException("Unknown tnf and type combination");
      }
    } else if (tnf == TNF_EXTERNAL_TYPE) {
      String externalType = String.fromCharCodes(type);
      String qualifiedName = externalType.split(":")[0];
      String qualifiedType = externalType.split(":")[1];
      return ExternalNdefRecord(tnf, type, id, payload, qualifiedName, qualifiedType, String.fromCharCodes(payload));
    } else {
      throw FormatException("Unknown tnf and type combination");
    }
  }
}

class TextNdefRecord extends NdefRecord {
  final String data;

  TextNdefRecord(tnf, type, id, payload, this.data) : super(tnf, type, id, payload);
}

class UriNdefRecord extends NdefRecord {
  final String uri;

  UriNdefRecord(tnf, type, id, payload, this.uri) : super(tnf, type, id, payload);
}

class ExternalNdefRecord extends NdefRecord {
  final String qualifiedName;
  final String qualifiedType;
  final String data;
  ExternalNdefRecord(tnf, type, id, payload, this.qualifiedName, this.qualifiedType, this.data) : super(tnf, type, id, payload);
}
