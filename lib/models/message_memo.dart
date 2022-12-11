import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oilstock/constants/constants.dart';

class MessageMemo {
  String idFrom = '';
  String idTo = '';
  String timestamp = '';
  String content = '';
  int type = 0;

  MessageMemo({
    required this.idFrom,
    required this.idTo,
    required this.timestamp,
    required this.content,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.idFrom: this.idFrom,
      FirestoreConstants.idTo: this.idTo,
      FirestoreConstants.timestamp: this.timestamp,
      FirestoreConstants.content: this.content,
      FirestoreConstants.type: this.type,
    };
  }

  factory MessageMemo.fromDocument(DocumentSnapshot doc) {
    String idFrom = doc.get(FirestoreConstants.idFrom);
    String idTo = doc.get(FirestoreConstants.idTo);
    String timestamp = doc.get(FirestoreConstants.timestamp);
    String content = doc.get(FirestoreConstants.content);
    int type = doc.get(FirestoreConstants.type);
    return MessageMemo(
        idFrom: idFrom,
        idTo: idTo,
        timestamp: timestamp,
        content: content,
        type: type);
  }

  MessageMemo.empty();

  factory MessageMemo.fromMap(Map<String, dynamic> json) {
    return MessageMemo(
        timestamp: json['timestamp'],
        idFrom: json['idFrom'],
        idTo: json['idTo'],
        content: json['content'],
        type: json['type']);
  }

  Map<String, dynamic> toMap() => {
        'timestamp': timestamp,
        'idFrom': idFrom,
        'idTo': idTo,
        'content': content,
        'type': type
      };
}
