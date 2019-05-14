class NdefTag {
  final String id;
 final  List<NdefRecord> records;

  NdefTag(this.id, this.records);
  factory NdefTag.fromJson(Map<String, dynamic> json) {
    var records =  json['records'] as List;
    return NdefTag(json['id'], records.map((recordJson) => NdefRecord.fromJson(recordJson)).toList());
  }

}

class NdefRecord {
  final String mimeType;
  final String payload;

  NdefRecord(this.mimeType, this.payload);

  NdefRecord.fromJson(Map<String, dynamic> json) : mimeType = json['mimeType'], payload = json['payload'];

}