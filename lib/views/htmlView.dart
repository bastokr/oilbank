import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

import 'httpCont.dart';

const String kNavigationExamplePage = '''
<!DOCTYPE html><html>
<head><title>Navigation Delegate Example</title></head>
<body>
<p>
The navigation delegate is set to block navigation to the youtube website.
</p>
<ul>
<ul><a href="https://www.youtube.com/">https://www.youtube.com/</a></ul>
<ul><a href="https://www.google.com/">https://www.google.com/</a></ul>
</ul>
</body>
</html>
''';
late WebViewController _controller;

late FToast fToast;

class HtmlView extends StatefulWidget {
  final value;
  final sbjt;
  final type;
  const HtmlView(
      {Key? key, required List<String> this.value, this.sbjt = "", this.type})
      : super(key: key);

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<HtmlView> {
  late ScrollController _scrollController;
  late String targetUrl = 'https://yeonfd.cafe24.com/custom/ship_and.php';
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
          title: Text(widget.sbjt ?? ""),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Hi!',
            onPressed: () => {Navigator.pop(context)},
          ),
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
                //initialUrl:
                //    'https://yeonfd.cafe24.com/custom/main_and.php?site=A',
                // initialUrl: 'https://youzan.github.io/vant/mobile.html#/zh-CN/uploader',
                javascriptMode: JavascriptMode.unrestricted,

                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;

                  _controller.loadUrl(Uri.dataFromString(
                          (widget.type == '1')
                              ? HtmlCont.getTable1(widget.value)
                              : HtmlCont.getTable2(widget.value),
                          mimeType: 'text/html',
                          encoding: Encoding.getByName('utf-8'))
                      .toString());

                  // _controller.complete(webViewController);
                },

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
}
