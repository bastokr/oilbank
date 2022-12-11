import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:oilstock/views/chat_list.dart';
import 'package:oilstock/views/gongji.dart';
import 'package:oilstock/views/order_main.dart';
import 'package:oilstock/views/ship_main.dart';
import 'package:oilstock/views/user_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import 'chat.dart';
import 'oil_main.dart';
import 'oil_map.dart';
import 'oil_market.dart';

//import 'package:golfgather/chatt/chatt.dart';
//import 'package:shared_preferences/shared_preferences.dart';

//import './views/map3.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:firebase_core/firebase_core.dart';

//import 'LoginPage.dart';

//import 'chatt/chatt.dart';
_MyAppState ppState = new _MyAppState();

class Main extends StatefulWidget {
  @override
  final sendtoken;
  final user_id;

  const Main(this.sendtoken, this.user_id, {Key? key}) : super(key: key);

  @override
  _MyAppState createState() => ppState;

  static final _myTabbedPageKey = new GlobalKey<_MyAppState>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('sendtoken', sendtoken));
  }
}

class _MyAppState extends State<Main> with SingleTickerProviderStateMixin {
  //late FirebaseMessaging messaging;
  late DefaultTabController _defaultTabController;
  late GlobalKey<_MyAppState> _keyChild1;
  var tabIndex = 0;
  var current = 0;
  var alerm_cnt = 0;
  var alerm_yn = false;
  var bottomNavigationBarHeigh = 60.0;

  late TabController ctr;

  @override
  void initState() {
    FlutterAppBadger.removeBadge();

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      if (event.notification != null) {
        if (current != 1) {
          message(context, event.notification);
        }

        SharedPreferences.getInstance().then((value) {
          //int cnt = 0;
          /*
          if (value.getInt('alerm_counter') != null) {
            cnt = value.getInt('alerm_counter')! + 1;
          }*/

          value.setInt('alerm_counter', 1);
          if (kDebugMode) {
            print(value.getInt('alerm_counter'));
          }
        });
      }

      //  print(event.notification!.body);
    });

    FirebaseMessaging.onBackgroundMessage((message) async {
      print('Message clicked!');
      FlutterAppBadger.updateBadgeCount(1);
    });
    super.initState();
    _keyChild1 = GlobalKey();
    ctr = TabController(vsync: this, length: 5);

    ctr.animation?.addListener(onTabChanged);

    fetchPost();
    alerm_cnt = 1;
  }

  void onTabChanged() {
    final aniValue = ctr.animation?.value;
    if (aniValue == 1) {
      if (kDebugMode) {
        print(aniValue);
      }
      //bottomNavigationBarHeigh = 0.0;
    } else {
      bottomNavigationBarHeigh = 60.0;
    }
    setState(() {});
    /*
    if (aniValue > 0.5 && index != 1) {
      setState(() {
        index = 1;
      });
    } else if (aniValue <= 0.5 && index != 0) {
      setState(() {
        index = 0;
      });
    }
  }
    */
  }

  fetchPost() async {
    final prefs = await SharedPreferences.getInstance();
/*
    String url =
        "https://luckytransportca.cafe24.com/mrfact/custom/dao/anListDao.php?tableName=shipCount";
    var response = await http
        .post(Uri.parse(url), body: {'user_id': prefs.getString("user_id")});

    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      var aaa = json.decode(response.body);
      // print(aaa['cnt']);
      setState(() {
        alerm_cnt = aaa['cnt'];
        if (alerm_cnt > 0) alerm_yn = true;
      });
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
    */
  }

  Future<void> message(
      BuildContext context, RemoteNotification? remoteNotification) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(remoteNotification?.title ?? ''),
          content: Text(remoteNotification?.body ?? ''),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () async {
                Navigator.of(context).pop();

                //  exit(0);
              },
            )
          ],
        );
      },
    );
  }

  Future moveTab(var index) async {
    print(index);
    if (index + 1 == _defaultTabController.length) {
      print(
          "===================================================================");
      final prefs = await SharedPreferences.getInstance();

      prefs.setString("user_id", "");
      prefs.setString("token", "");

      _asyncConfirmDialog(context);
    } else {
      ctr.index = index;
      current = index;
    }
  }

  Future<void> _asyncConfirmDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('로그아웃 하시겠습니까?'),
          content: Text(''),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                setState(() async {
                  print(current);
                  Navigator.of(context).pop();
                  ctr.index = current;
                });
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                exit(0);
              },
            )
          ],
        );
      },
    );
  }

  //TabController controller;
  @override
  Widget build(BuildContext context) {
    return _defaultTabController = DefaultTabController(
      length: 5,
      initialIndex: tabIndex,
      child: Scaffold(
          body: TabBarView(
            controller: ctr,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const MainHome(),
              OilMap(widget.sendtoken, widget.user_id),
              const OilMarket(),
              UserMain(widget.sendtoken, widget.user_id),
              const Text(''),
            ],
          ),
          bottomNavigationBar: Material(
            color: Colors.redAccent,
            child: SizedBox(
              height: bottomNavigationBarHeigh,
              child: TabBar(
                onTap: (int index) {
                  moveTab(index);
                },
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: Colors.transparent,
                controller: ctr,
                tabs: <Widget>[
                  Column(children: [
                    expandedBadge(Icons.home, "1", false),
                    const Text(
                      "메인",
                      style: TextStyle(fontSize: 12),
                    )
                  ]),
                  Column(children: [
                    expandedBadge(Icons.search, alerm_cnt.toString(), alerm_yn),
                    const Text(
                      "검색",
                      style: TextStyle(fontSize: 12),
                    )
                  ]),
                  Column(children: [
                    expandedBadge(
                        Icons.notifications_active_rounded, "1", false),
                    const Text(
                      "공지",
                      style: TextStyle(fontSize: 12),
                    )
                  ]),
                  Column(children: [
                    expandedBadge(Icons.list, "1", false),
                    const Text(
                      "My",
                      style: TextStyle(fontSize: 12),
                    )
                  ]),
                  Column(children: [
                    expandedBadge(Icons.logout, "1", false),
                    const Text(
                      "나가기",
                      style: TextStyle(fontSize: 12),
                    )
                  ]),
                ],
              ),
            ),
          )),
    );
  }

  Widget expandedBadge(icon, count, show) {
    return Expanded(
      child: Center(
        child: Badge(
          showBadge: show,
          badgeContent: Text(count),
          child: Icon(icon, size: 30),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("dispose() of _SecondPage");
    FlutterAppBadger.removeBadge();
    super.dispose();
  }
}
