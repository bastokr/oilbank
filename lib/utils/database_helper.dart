import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler {
  Future<Database> initializedDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, "auction3.db"),
      onCreate: (database, version) {
        var query = "";
        query = query +
            " create table auction3 (	aucNo	 integer primary key autoincrement	,";
        query = query +
            "		sbjt text,aucM1 text,aucM2 text,pnotMyM1 text,pnotMyM2 text,pnotMyME1 text,pnotMyME2 text,";
        query = query + "		grtM1 text,grtM2 text,grtMW1 text,grtMW2 text,";
        query = query +
            "		etc1 text,etc2 text,etc3 text,etc4 text,etc5 text,etc6 text,etc7 text,etc8 text)";
        print(query);
        database.execute(query);
      },
      version: 3,
    );
  }

  Future<int> insertUser(Auction3 user) async {
    final Database db = await initializedDB();
    db.delete('auction3', where: 'sbjt= ?', whereArgs: [user.sbjt]);

    return await db.insert('auction3', user.toMap());
  }

  Future<List<Auction3>> getAllUsers() async {
    final Database db = await initializedDB();
    List<Map<String, dynamic>> result = await db.query('auction3');
    return result.map((e) => Auction3.fromMap(e)).toList();
  }

  Future<List<Auction3>> getUser(aucNo) async {
    final Database db = await initializedDB();

    List<Map<String, dynamic>> result =
        await db.query('auction3', where: 'aucNo= ?', whereArgs: [aucNo]);

    return result.map((e) => Auction3.fromMap(e)).toList();
  }

  Future<void> deleteUser(int aucNo) async {
    final Database db = await initializedDB();
    db.delete('auction3', where: 'aucNo= ?', whereArgs: [aucNo]);
  }

  Future<void> updateUsingHelper(Auction3 auction3) async {
    final Database db = await initializedDB();
    await db.update('auction3', auction3.toMap(),
        where: 'aucNo= ?', whereArgs: [auction3.aucNo]);
  }
}

class Auction3 {
  int aucNo = 0;
  String sbjt = "";
  String aucM1 = "";
  String aucM2 = '';
  String pnotMyM1 = '';
  String pnotMyM2 = '';
  String pnotMyME1 = '';
  String pnotMyME2 = '';
  String grtM1 = '';
  String grtM2 = '';
  String grtMW1 = '';
  String grtMW2 = '';
  String etc1 = '';
  String etc2 = '';
  String etc3 = '';
  String etc4 = '';
  String etc5 = '';
  String etc6 = '';
  String etc7 = '';
  String etc8 = '';

  Auction3.empty();

  Auction3(
      {required this.aucNo,
      required this.sbjt,
      required this.aucM1,
      required this.aucM2,
      required this.pnotMyM1,
      required this.pnotMyM2,
      required this.pnotMyME1,
      required this.pnotMyME2,
      required this.grtM1,
      required this.grtM2,
      required this.grtMW1,
      required this.grtMW2,
      required this.etc1,
      required this.etc2,
      required this.etc3,
      required this.etc4,
      required this.etc5,
      required this.etc6,
      required this.etc7,
      required this.etc8});

  factory Auction3.fromMap(Map<String, dynamic> json) {
    return Auction3(
        aucNo: json['aucNo'],
        sbjt: json['sbjt'],
        aucM1: json['aucM1'],
        aucM2: json['aucM2'],
        pnotMyM1: json['pnotMyM1'],
        pnotMyM2: json['pnotMyM2'],
        pnotMyME1: json['pnotMyME1'],
        pnotMyME2: json['pnotMyME2'],
        grtM1: json['grtM1'],
        grtM2: json['grtM2'],
        grtMW1: json['grtMW1'],
        grtMW2: json['grtMW2'],
        etc1: json['etc1'],
        etc2: json['etc2'],
        etc3: json['etc3'],
        etc4: json['etc4'],
        etc5: json['etc5'],
        etc6: json['etc6'],
        etc7: json['etc7'],
        etc8: json['etc8']);
  }

  Map<String, dynamic> toMap() => {
        'sbjt': sbjt,
        'aucM1': aucM1,
        'aucM2': aucM2,
        'pnotMyM1': pnotMyM1,
        'pnotMyM2': pnotMyM2,
        'pnotMyME1': pnotMyME1,
        'pnotMyME2': pnotMyME2,
        'grtM1': grtM1,
        'grtM2': grtM2,
        'grtMW1': grtMW1,
        'grtMW2': grtMW2,
        'etc1': etc1,
        'etc2': etc2,
        'etc3': etc3,
        'etc4': etc4,
        'etc5': etc5,
        'etc6': etc6,
        'etc7': etc7,
        'etc8': etc8
      };
}
