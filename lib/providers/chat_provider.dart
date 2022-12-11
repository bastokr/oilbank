import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:oilstock/constants/constants.dart';
import 'package:oilstock/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatProvider(
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
        .collection('withChat')
        .doc(id);

    firebaseFirestore
        .collection(collectionPath)
        .doc(id)
        .get()
        .then((querySnapshot) {
      var json = querySnapshot.get('photoUrl');
      print(querySnapshot.data().toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'id': id,
            'photoUrl': querySnapshot.get('photoUrl'),
            'nickname': querySnapshot.get('nickname')
          },
        );
      });
    });
  }

  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  void sendMessage(String content, int type, String groupChatId,
      String currentUserId, String peerId) {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    MessageChat messageChat = MessageChat(
      idFrom: currentUserId,
      idTo: peerId,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
    );

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        messageChat.toJson(),
      );
    });

    firebaseFirestore
        .collection('users')
        .doc(peerId)
        .get()
        .then((querySnapshot) {
      var token = querySnapshot.get('pushToken');
      print(querySnapshot.data().toString());

      Future<http.Response> rs = sendTokenMessage(content, token);
      rs.then((value) => {print(value)});
    });
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

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const imageByte = 3;
  static const sticker = 2;
}
