import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:oilstock/views/image_view.dart';
import 'package:oilstock/views/oil_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

late WebViewController _controller;

late FToast fToast;

class Gongji extends StatefulWidget {
  final token;
  final user_id;
  const Gongji(this.token, this.user_id, {Key? key}) : super(key: key);

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<Gongji> {
  late ScrollController _scrollController;
  late String imgPath = 'https://iukj.cafe24.com/shop/custom/';
  late String targetUrl = 'https://iukj.cafe24.com/shop/custom/board_and.php';
  late bool check, check1;
  late SharedPreferences prefs;
  late bool telShow = false;
  late bool kakaoUrlShow = false;
  late String tel;
  late String kakaoUrl;
  _scrollListener() {
    if (_scrollController.offset <=
            _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {
      _controller.reload();
    }
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast().init(context);
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    fetchPost2();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    check = false;
    check1 = false;
  }

  fetchPost2() async {
    prefs = await SharedPreferences.getInstance();

    if (prefs.getString("kakaoUrl").toString() != "") {
      kakaoUrlShow = true;
    }

    if (prefs.getString("tel").toString() != "") {
      telShow = true;
    }
    kakaoUrl = prefs.getString("kakaoUrl").toString();
    tel = prefs.getString("tel").toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber[900],
          title: const Text('추천매물'),
          leading: IconButton(
            icon: const Icon(Icons.home),
            tooltip: '샐러켓',
            onPressed: () => {
              _controller.loadUrl(imgPath + '/home.php', headers: {
                'x-auth-token': widget.token,
                'x-request-id': widget.user_id
              })
            },
          ),
          actions: <Widget>[
            Row(mainAxisSize: MainAxisSize.min, children: [
              ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.amber[900],
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _controller.loadUrl(targetUrl, headers: {
                      'x-auth-token': widget.token,
                      'x-request-id': widget.user_id
                    });
                  });
                },
                icon: const Icon(
                  // <-- Icon
                  Icons.notifications_active_rounded,
                  size: 24.0,
                ),
                label: const Text('리스트'), // <-- Text
              ),
            ])
          ],
        ),
        // We're using a Builder here so we have a context that is below the Scaffold
        // to allow calling Scaffold.of(context) so we can show a snackbar.
        body: Builder(builder: (BuildContext context) {
          Future<bool> _goBack(BuildContext context) async {
            if (await _controller.canGoBack()) {
              _controller.goBack();
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          }

          return WillPopScope(
              onWillPop: () => _goBack(context),
              child: WebView(
                javascriptMode: JavascriptMode.unrestricted,

                gestureRecognizers: {
                  Factory<PlatformViewVerticalGestureRecognizer>(
                    () => PlatformViewVerticalGestureRecognizer(kind: null)
                      ..onUpdate = (_) {
                        print('aaa');
                      },
                  ),
                },
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  webViewController.loadUrl(targetUrl, headers: {
                    'x-auth-token': widget.token,
                    'x-request-id': widget.user_id
                  });
                  // _controller.complete(webViewController);
                },
                onProgress: (int progress) {
                  print("WebView is loading (progress : $progress%)");
                },
                javascriptChannels: <JavascriptChannel>{
                  _toasterJavascriptChannel(context),
                  gotoShipMain(context),
                  getImageView(context),
                  gotoLogin(context)
                },
                navigationDelegate: (NavigationRequest request) {
                  if (request.url.startsWith('https://www.youtube.com/')) {
                    print('blocking navigation to $request}');
                    return NavigationDecision.prevent;
                  }
                  print('allowing navigation to $request');
                  return NavigationDecision.navigate;
                },
                onPageStarted: (String url) {
                  print('Page started loading: $url');
                },
                onPageFinished: (String url) {
                  print('Page finished loading: $url');
                  setState(() {
                    bool temp = check;
                    check = true;
                    if (!temp) _controller.scrollBy(0, 10);
                  });
                },
                gestureNavigationEnabled: true,
                // geolocationEnabled: true,
              ));
        }),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (kakaoUrlShow)
              FloatingActionButton.small(
                heroTag: 'chat',
                onPressed: () {
                  launch(kakaoUrl);
                },
                child: Image.asset("assets/icon/free-icon.png",
                    width: 30, height: 30),
              ),
            const SizedBox(
              height: 8,
            ),
            if (telShow)
              FloatingActionButton.small(
                heroTag: 'phone',
                onPressed: () {
                  launch("tel: " + tel);
                },
                child: const Icon(Icons.phone),
              ),
          ],
        ));
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  JavascriptChannel gotoShipMain(BuildContext context) {
    return JavascriptChannel(
        name: 'gotoShipMain',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          setState(() {
            //ppState.moveTab(1);
          });
        });
  }

  JavascriptChannel gotoLogin(BuildContext context) {
    return JavascriptChannel(
        name: 'gotoLogin',
        onMessageReceived: (JavascriptMessage message) async {
          // ignore: deprecated_member_use

          print(
              "===================================================================");

          prefs.remove("user_id");
          prefs.remove("token");

          setState(() {});
        });
  }

  JavascriptChannel getImageView(BuildContext context) {
    return JavascriptChannel(
        name: 'getImageView',
        onMessageReceived: (JavascriptMessage message) {
          print(message.message);
          // ignore: deprecated_member_use
          Navigator.push(
              context,
              // ignore: prefer_const_constructors
              MaterialPageRoute(
                  builder: (context) => ImageView(imgPath + message.message)));
        });
  }
}

enum MenuOptions {
  showUserAgent,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
  navigationDelegate,
  geolocation
}

const IconData refresh = IconData(0xe514, fontFamily: 'S-Core');

class PlatformViewVerticalGestureRecognizer
    extends VerticalDragGestureRecognizer {
  PlatformViewVerticalGestureRecognizer({PointerDeviceKind? kind})
      : super(kind: kind);

  Offset _dragDistance = Offset.zero;

  @override
  void addPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
  }

  @override
  void handleEvent(PointerEvent event) {
    _dragDistance = _dragDistance + event.delta;
    _controller.getScrollY().then((value) {
      print(value);
    });
  }

/*
  @override
  void handleEvent(PointerEvent event) {
    _dragDistance = _dragDistance + event.delta;
    print(
        "=========================================================================");

    if (event is PointerScrollEvent) {
      final double dy = _dragDistance.dy.abs();
      final double dx = _dragDistance.dx.abs();

      if (dy > dx && dy > kTouchSlop) {
        // vertical drag - accept
        resolve(GestureDisposition.accepted);
        _dragDistance = Offset.zero;
      } else if (dx > kTouchSlop && dx > dy) {
        resolve(GestureDisposition.accepted);
        // horizontal drag - stop tracking
        stopTrackingPointer(event.pointer);
        _dragDistance = Offset.zero;
      }
    }
  }
*/
  @override
  String get debugDescription => 'horizontal drag (platform view)';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
