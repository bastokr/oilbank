import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:oilstock/constants/constants.dart';
import 'package:oilstock/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/message_memo.dart';
import 'package:oilstock/utils/database_memo.dart';

class MemoProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  MemoProvider(
      {required this.firebaseFirestore,
      required this.prefs,
      required this.firebaseStorage});

  String? getPref(String key) {
    return prefs.getString(key);
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  void addCallactionDataFirestore(
      String collectionPath, String docPath, String id) {
    DocumentReference documentReference = firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .collection('withMemo')
        .doc(id);
  }

  Stream<QuerySnapshot> getMemoStream(String groupMemoId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupMemoId)
        .collection(groupMemoId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<List<MessageMemo>> getMemoList(String groupMemoId, int limit) {
    return DatabaseMemo().getAllDatas();
  }

  Future<int> sendMessage(String content, int type, String groupMemoId,
      String currentUserId, String peerId) async {
    MessageMemo messageMemo = MessageMemo(
      idFrom: currentUserId,
      idTo: peerId,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
    );

    return DatabaseMemo().insertData(messageMemo);
  }

  Future<http.Response> sendTokenMessage(String content, String token) {
    return http.post(
      Uri.parse('https://iukj.cafe24.com/ybauction/sendmessage.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'messageToken': token,
        'content': content,
      }),
    );
  }
}
