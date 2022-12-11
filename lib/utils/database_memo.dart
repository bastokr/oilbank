import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart';
import '../models/message_memo.dart';

class DatabaseMemo {
  Future<Database> initializedDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, "Memo.db"),
      onCreate: (database, version) {
        var query = "";
        query = query + " create table Memo (	timestamp	 text	,";
        query = query + "		idFrom text,idTo text,content text,type integer ) ";

        database.execute(query);
      },
      version: 1,
    );
  }

  Future<int> insertData(MessageMemo memo) async {
    final Database db = await initializedDB();
    // db.delete('Memo', where: 'timestamp= ?', whereArgs: [user.timestamp]);

    return await db.insert('Memo', memo.toMap());
  }

  Future<List<MessageMemo>> getAllDatas() async {
    final Database db = await initializedDB();
    List<Map<String, dynamic>> result =
        await db.query('Memo', orderBy: "timestamp desc");
    return result.map((e) => MessageMemo.fromMap(e)).toList();
  }

  Future<List<MessageMemo>> getData(timestamp) async {
    final Database db = await initializedDB();

    List<Map<String, dynamic>> result =
        await db.query('Memo', where: 'timestamp= ?', whereArgs: [timestamp]);

    return result.map((e) => MessageMemo.fromMap(e)).toList();
  }

  Future<void> deleteData(int timestamp) async {
    final Database db = await initializedDB();
    db.delete('Memo', where: 'timestamp= ?', whereArgs: [timestamp]);
  }

  Future<void> updateUsingHelper(MessageMemo auction3) async {
    final Database db = await initializedDB();
    await db.update('Memo', auction3.toMap(),
        where: 'timestamp= ?', whereArgs: [auction3.timestamp]);
  }
}
