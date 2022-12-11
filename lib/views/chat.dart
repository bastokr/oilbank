import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
//import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'dog/db_dog.dart';

class ChatDetailPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatDetailPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(id: '06c33e8b-e835-4736-80f4-63f44b66666c');
  var database = null;
  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      if (event.notification != null) {
        var messagenoti = jsonDecode(event.notification?.body ?? '');
        _addMessage(types.Message.fromJson(messagenoti));
        SharedPreferences.getInstance().then((value) {
          if (kDebugMode) {
            print(value.getInt('alerm_counter'));
          }
        });
      }

      //  print(event.notification!.body);
    });

    super.initState();
    getConnection().then(
      (value) => {database = value, _loadMessages(database)},
    );
  }

  Future<void> _addMessage(types.Message message) async {
    setState(() {
      _messages.insert(0, message);
    });
    var fido = Dog(
      id: 0,
      name: jsonEncode(_messages),
      age: 35,
    );
    final Database db = await database;

    // Dog를 올바른 테이블에 추가하세요. 또한
    // `conflictAlgorithm`을 명시할 것입니다. 본 예제에서는
    // 만약 동일한 dog가 여러번 추가되면, 이전 데이터를 덮어쓸 것입니다.

    db.update(
      'dogs',
      fido.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    getAllDogs();
  }

  Future<List<dynamic>> getAllDogs() async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM dogs where id=0');
    List<dynamic> list = res.isNotEmpty
        ? res
            .map((c) => Dog(id: c['id'], name: c['name'], age: c['age']))
            .toList()
        : [];
    Set<Dog> set = Set.from(list);
    set.forEach((element) {
      print(element.id);
      print(element.name);
      print(element.age);
    });
    return list;
  }

  Future<Database> getConnection() async {
    return openDatabase(
      // 데이터베이스 경로를 지정합니다. 참고: `path` 패키지의 `join` 함수를 사용하는 것이
      // 각 플랫폼 별로 경로가 제대로 생성됐는지 보장할 수 있는 가장 좋은 방법입니다.
      path.join(await getDatabasesPath(), 'doggie_database.db'),
      // 데이터베이스가 처음 생성될 때, dog를 저장하기 위한 테이블을 생성합니다.
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE IF NOT EXISTS  dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)",
        );
      },
      // 버전을 설정하세요. onCreate 함수에서 수행되며 데이터베이스 업그레이드와 다운그레이드를
      // 수행하기 위한 경로를 제공합니다.
      version: 1,
    );
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleImageSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Photo'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleFileSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('File'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    if (message is types.FileMessage) {
      // await OpenFile.open(message.uri);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    //final updatedMessage = _messages[index].copyWith(previewData: previewData);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        //  _messages[index] = updatedMessage;
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
  }

  void _loadMessages(database) async {
/*

    final response = await rootBundle.loadString('assets/messages.json');
    final messages = (jsonDecode(response) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();
*/

    final db = await database;
    var res = await db.rawQuery('SELECT * FROM dogs where id=0 ');

    print(res.first['name']);
    final messages = (jsonDecode(res.first['name']) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();
    setState(() {
      _messages = messages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OIL STOCK'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // <- 아이콘도 동일한 것을 사용
          onPressed: () {
            Navigator.pop(context); // <- 이전 페이지로 이동.
          },
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Chat(
          messages: _messages,
          onAttachmentPressed: _handleAtachmentPressed,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          user: _user,
        ),
      ),
    );
  }
}
