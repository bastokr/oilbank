import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/components/button/gf_button_bar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/position/gf_position.dart';
import 'package:getwidget/types/gf_button_type.dart';
import 'package:oilstock/utils/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../constants/color_constants.dart';

class OilMarket extends StatefulWidget {
  const OilMarket({Key? key}) : super(key: key);

  @override
  State<OilMarket> createState() => _HomeState();
}

class _HomeState extends State<OilMarket> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final StreamController _streamController = StreamController();
  @override
  void initState() {
    getData();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    // controller.repeat(reverse: true);

    super.initState();
  }

  Future<List<Auction3>> getUsersLIst() async {
    return await DatabaseHandler().getAllUsers();
  }

  int _count = 0;
  final descTextStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w800,
    fontFamily: 'Roboto',
    letterSpacing: 0.5,
    fontSize: 18,
    height: 2,
  );

  Future getData() async {
    var url = 'https://iukj.cafe24.com/api/list/oilstock/MENU_MGT_S005_S102';
    var url2 = Uri.parse(url);

    http.Response response = await http.get(url2);

    var data = jsonDecode(response.body);

    _streamController.add(data['rows']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber[900],
          title: const Text('곤지암 GS 칼텍스 주유소'),
          leading: IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Hi!',
            onPressed: () => {},
          ),
        ),
        // We're using a Builder here so we have a context that is below the Scaffold
        // to allow calling Scaffold.of(context) so we can show a snackbar.

        body: Builder(builder: (BuildContext context) {
          const labelTextStyle =
              TextStyle(fontSize: 10, fontStyle: FontStyle.italic);

          DatabaseHandler dbHandler = DatabaseHandler();

          return DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyText2!,
            child: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.minHeight,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          color: Colors.grey[200],
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 600),
                            switchInCurve: Curves.easeIn,
                            switchOutCurve: Curves.easeOut,
                            child: Column(children: <Widget>[
                              Container(
                                color: Colors.blue[800],
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 240,
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Image.network(
                                            'https://iukj.cafe24.com/msite/uploads/MENU_MGT_S005_S100833.PNG',
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            fit: BoxFit.cover,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width - 50,
                            height: 100.0,
                            child: Row(children: [
                              GFAvatar(
                                backgroundImage:
                                    AssetImage('assets/icon/oilbank.png'),
                              ),
                              SizedBox(width: 10),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('곤지암 GS칼텍스 주유소',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17)),
                                  Text('주소: 경기광주시 곤지암읍 888번지')
                                ],
                              ),
                              SizedBox(width: 20, height: 10),
                              SizedBox(
                                  width: 50,
                                  child: Center(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.map,
                                            size: 30,
                                            color: Colors.red,
                                          ),
                                          Text(
                                            '12KM',
                                            style: TextStyle(color: Colors.red),
                                          )
                                        ]),
                                  ))
                            ])),
                        /* const GFListTile(
                          avatar: GFAvatar(
                            backgroundImage:
                                AssetImage('assets/icon/oilbank.png'),
                          ),
                          titleText: '곤지암 GS칼텍스 주유소',
                          subTitleText: '주소: 경기광주시 곤지암읍 888번지',
                          icon: Center(
                            child: Text(
                              '  반경\n\r12KM',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                        */
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                '휴발유:  ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                '1,850원',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.red,
                                    fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                ' 경 유 : ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                '1,850원',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.red,
                                    fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                ' 등 유 : ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                '1,850원',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.red,
                                    fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                        GFButton(
                          onPressed: () {},
                          text: "보관하기",
                          fullWidthButton: true,
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                          blockButton: true,
                          type: GFButtonType.solid,
                        ),
                        Container(
                          // A fixed-height child.
                          color: Colors.red, // Yellow
                          height: 30.0,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          child: const Text(' 보관내역 ',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                        ),
                        Ink(
                          color: Colors.white,
                          height: 400,
                          width: double.infinity,
                          child: StreamBuilder(
                            stream: _streamController.stream,
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                return ListView(
                                  children:
                                      snapshot.data.map<Widget>((document) {
                                    return GFListTile(
                                        color: Colors.white,
                                        titleText: document['주유소명'],
                                        subTitle: Row(
                                          children: [
                                            SizedBox(
                                              width: 200,
                                              child: Text(document['주소'],
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.blue)),
                                            ),
                                            Text(
                                              document['보관유류량'] + "L",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.red),
                                            ),
                                          ],
                                        ),
                                        //subTitleText: document['주소'],
                                        icon: Icon(
                                          Icons.favorite,
                                          color: Colors.amber,
                                        ));
                                  }).toList(),
                                );
                              }
                              return const Text('Loading...');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }));
  }

  bool _isShown = true;

  void _delete(BuildContext context, dbHandler, user) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: const Text('삭제하기'),
            content: const Text('해당물건을 삭제하시겠습니까?'),
            actions: [
              // The "Yes" button
              CupertinoDialogAction(
                onPressed: () {
                  dbHandler.deleteUser(user.aucNo);

                  Navigator.of(context).pop();
                  initState();
                  setState(() {});
                },
                child: const Text('삭제'),
                isDefaultAction: true,
                isDestructiveAction: true,
              ),
              // The "No" button
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('취소'),
                isDefaultAction: false,
                isDestructiveAction: false,
              )
            ],
          );
        });
  }

  double nullChangeValue(String editText) {
    try {
      return double.parse(editText);
    } on Exception {
      return 0.0;
    }
  }

  String doubleToString(double d) {
    return chage000(d);
  }

  String doubleNotIntToString(double d) {
    // d=Math.round(d*100/11)/100;
    return (d.toString());
  }

  double nullChangeDoubleValue(String editText) {
    return double.parse(editText);
  }

  String chage000(double str) {
    // Thousand-separator
    var f = NumberFormat('###,###,###,###.##');
    return f.format(str);
  }
}
