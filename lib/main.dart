import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oilstock/views/check_passwd.dart';
import 'package:oilstock/views/lib.dart';
import 'package:oilstock/views/oil_home.dart';
import 'package:oilstock/views/regi_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _idTextEditController = TextEditingController();
  final _passwordTextEditController = TextEditingController();

  @override
  void initState() {
    checkLogin();
    firebaseSetting();
    _idTextEditController.text = 'parksk66@gmail.com';

    super.initState();
  }

  void checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getString("user_id") ?? "") != "") {
      Route route = MaterialPageRoute(
          builder: (context) =>
              Main(prefs.getString("token"), prefs.getString("user_id")));
      Navigator.pushReplacement(context, route);
    }
  }

  bool _isValid() {
    return (_idTextEditController.text.length >= 0 &&
        _passwordTextEditController.text.length >= 0);
  }

  void _login() {
    List pdList;
  }

  void loginSend() async {
    if (!_isValid()) {
      Fluttertoast.showToast(
          msg: "아이디와 비밀번호를 입력하세요 ^^",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    var postData = <String, String>{
      'mid': _idTextEditController.value.text,
      'psw': _passwordTextEditController.value.text,
      'messageToken': messageToken
    };
    var gubun = {"BL": "loginCheck_and"};
    NetworkHelper('/mrfact/custom/dao/memberDao.php')
        .getPostData(postData, gubun)
        .then((josonValue) async {
      print(josonValue["loginOk"]);

      if (josonValue["loginOk"] == 'Y') {
        final prefs = await SharedPreferences.getInstance();

        prefs.setString("user_id", _idTextEditController.value.text);
        prefs.setString("token", josonValue["token"]);
        Route route = MaterialPageRoute(
            builder: (context) =>
                Main(josonValue["token"], _idTextEditController.value.text));
        Navigator.pushReplacement(context, route);
      } else {
        Fluttertoast.showToast(
            msg: "입력하신 아이디/비밀번호가 맞지않습니다.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      // Map<String, dynamic> obj = jsonDecode(josonValue);
      //  print(obj["loginOk"]);

      setState(() {
        //   pdList = value;
      });
    });

    // 로그인 하기
  }

  void _signup() {
    // 회원가입 하기
  }

  @override
  Widget build(BuildContext context) {
    var _idTextField = CupertinoTextField(
      controller: _idTextEditController,
      placeholder: "아이디",
      padding: EdgeInsets.all(10),
      style: TextStyle(fontSize: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      onChanged: (text) {
        setState(() {});
      },
    );

    var _passwordTextField = CupertinoTextField(
      controller: _passwordTextEditController,
      placeholder: "비밀번호",
      obscureText: true,
      padding: EdgeInsets.all(10),
      style: TextStyle(fontSize: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      onChanged: (text) {
        setState(() {});
      },
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 210.0),
              child: Center(
                child: Center(
                  child: Image(
                    image: AssetImage('assets/icon/launcher_icon_main.png'),
                    width: 100,
                  ),
                ),
              ),
            ),

            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: _idTextField,
            ),
            Padding(
                padding: EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: _passwordTextField),
            // ignore: deprecated_member_use
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CheckPasswd()),
                );
              },
              child: const Text(
                '비밀번호 확인',
              ),
            ),

            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              // ignore: deprecated_member_use
              child: TextButton(
                onPressed: () {
                  loginSend();
                  /*Navigator.push(
                      context, MaterialPageRoute(builder: (_) => Main()));
                */
                },
                child: const Text(
                  '로그인',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
            const SizedBox(
              height: 130,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => regiUser()));
              },
              child: const Text(
                '회원가입',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _idTextEditController.dispose();
    _passwordTextEditController.dispose();
    super.dispose();
  }

  late FirebaseMessaging messaging;
  late String messageToken;
  firebaseSetting() {
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) async {
      print(value);
      final prefs = await SharedPreferences.getInstance();
      messageToken = value!;
      //  prefs.setString("messageToken", value!);
    });

    FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance
        .requestPermission(sound: true, badge: true, alert: true);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
      FlutterAppBadger.updateBadgeCount(1);
    });

    FirebaseMessaging.onBackgroundMessage((message) async {
      //await Firebase.initializeApp();

      print('Message clicked!');
      FlutterAppBadger.updateBadgeCount(1);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage rm) {
      print('onMessage clicked!');
      FlutterAppBadger.updateBadgeCount(1);
    });

    //FirebaseMessaging.instance.
  }
}
