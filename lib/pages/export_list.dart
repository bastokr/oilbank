import 'package:oilstock/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:getwidget/getwidget.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'chat_export.dart';
import 'export_page.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Server',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const ExportList(title: 'Flutter Server App'),
    );
  }
}

class ExportList extends StatefulWidget {
  const ExportList({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _ExportListState createState() => _ExportListState();
}

class _ExportListState extends State<ExportList> {
  final StreamController _streamController = StreamController();
  late Timer _timer;

  Future getData() async {
    var url = 'https://iukj.cafe24.com/api/list/ybauction/MENU_MGT_S005_S100';
    var url2 = Uri.parse(url);

    http.Response response = await http.get(url2);

    var data = jsonDecode(response.body);
    //Add your data to stream

    data['rows'].sort((a, b) {
      print(a['순서']);
      print(b['순서']);
      return a['순서'].compareTo(b['순서']) as int;
    });

    List arr = data['rows'];
    /*
    arr.where((e) {
      return e['승인유무'] == 'N';
    });
*/
    List a = [];
    for (var e in arr) {
      if (e['승인유무'] != 'N') a.add(e);
    }

    _streamController.add(a);
  }

  @override
  void initState() {
    getData();

    //Check the server every 5 seconds
    // _timer = Timer.periodic(Duration(seconds: 5), (timer) => getData());

    super.initState();
  }

  @override
  void dispose() {
    //cancel the timer
    if (_timer.isActive) _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 29, 241, 142),
        title: const Text('전문가상담'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          tooltip: '샐러켓',
          onPressed: () => {},
        ),
        actions: <Widget>[
          Row(mainAxisSize: MainAxisSize.min, children: [
            ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Color.fromARGB(255, 8, 160, 31),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExportAdd(),
                  ),
                );
              },
              icon: const Icon(
                color: Colors.white,
                // <-- Icon
                Icons.person_add,
                size: 24.0,
              ),
              label: const Text('등록요청',
                  style: TextStyle(color: Colors.white)), // <-- Text
            ),
          ])
        ],
      ),
      body: StreamBuilder(
        stream: _streamController.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data.map<Widget>((document) {
                return GFCard(
                  boxFit: BoxFit.cover,
                  image: Image.asset('your asset image'),
                  title: GFListTile(
                    avatar: GFAvatar(
                      backgroundImage: NetworkImage(document['사진']),
                    ),
                    title: Text(
                      document['성명'],
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 48, 48, 48)),
                    ),
                    subTitle: Text("[ " + document['타이틀'] + " ]",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 78, 77, 77))),
                  ),
                  content: Text(document['설명'],
                      style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 64, 64, 64))),
                  buttonBar: GFButtonBar(
                    children: <Widget>[
                      GFButton(
                        color: Color.fromARGB(255, 227, 84, 2),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatExport(
                                arguments: ChatPageArguments(
                                  peerId: document['id'],
                                  peerAvatar: document['사진'],
                                  peerNickname: document['성명'],
                                ),
                              ),
                            ),
                          );
                        },
                        text: ' 채팅상담 ',
                      ),
                      GFButton(
                        color: Color.fromARGB(255, 232, 134, 6),
                        onPressed: () {},
                        text: ' 카톡상담 ',
                      ),
                      GFButton(
                        color: Color.fromARGB(255, 2, 94, 139),
                        onPressed: () {},
                        text: ' 프로필',
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }
          return const Text('Loading...');
        },
      ),
    );
  }
}
