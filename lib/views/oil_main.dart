import 'dart:async';
import 'dart:convert';

import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/components/button/gf_button_bar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:oilstock/pages/chat_export.dart';
import 'package:oilstock/utils/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class MainHome extends StatefulWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  State<MainHome> createState() => _HomeState();
}

class _HomeState extends State<MainHome> with SingleTickerProviderStateMixin {
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
    //Add your data to stream
/*
    data['rows'].sort((a, b) {
      return a['순서'].compareTo(b['순서']) as int;
    });

    List arr = data['rows'];
    List a = [];
    for (var e in arr) {
      if (e['승인유무'] != 'N') a.add(e);
    }
*/
    _streamController.add(data['rows']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber[900],
          title: const Text('OIL STOCK'),
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
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Image(
                                                    image: AssetImage(
                                                        'images/icon/oilstock.png'),
                                                    width: 100,
                                                    fit: BoxFit.fill),
                                                Text(
                                                  '   지금 가격에',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                                Text(
                                                  '   보관해서 쓴다.',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                                SizedBox(
                                                  height: 50,
                                                ),
                                                OutlinedButton(
                                                  style: ButtonStyle(
                                                    shape: MaterialStateProperty
                                                        .all<RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18.0),
                                                      //side: BorderSide(color: Colors.red) // border line color
                                                    )),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith<
                                                                Color?>((Set<
                                                                    MaterialState>
                                                                states) {
                                                      return Colors
                                                          .red; // Defer to the widget's default.
                                                    }),
                                                  ),
                                                  onPressed: () async {},
                                                  child: Container(
                                                      alignment:
                                                          Alignment.topCenter,
                                                      child: SizedBox(
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Icon(
                                                              Icons.push_pin,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            Text(' 보 관 하 기 ',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                )),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                )
                                              ]),
                                          SizedBox(
                                            width: 40,
                                          ),
                                          Image(
                                              image: AssetImage(
                                                  'images/icon/Frame.png'),
                                              width: 150,
                                              fit: BoxFit.fill),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ]),
                          ),
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
