import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';

class KakaoMap extends StatefulWidget {
  KakaoMap({required Key key, query}) : super(key: key);

  @override
  _KakaoMapState createState() => _KakaoMapState();
}

class _KakaoMapState extends State<KakaoMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebView(
          initialUrl:
              'https://map.kakao.com/?q=%ED%99%8D%EB%8C%80%20%EB%A7%88%EB%A6%AC%EC%98%A4',
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
