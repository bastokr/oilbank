import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';

class ThemaMap extends StatefulWidget {
  @override
  State<ThemaMap> createState() => ThemaMapState();
}

class ThemaMapState extends State<ThemaMap> {
  late BitmapDescriptor pinLocationIcon;
  @override
  void initState() {
    super.initState();
    setCustomMapPin();
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/icon/pin.png');
  }

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.413294, 126.734086),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    LatLng pinPosition = LatLng(37.4979278, 127.0275833);

    // these are the minimum required values to set
    // the camera position
    CameraPosition initialLocation =
        CameraPosition(zoom: 16, bearing: 30, target: pinPosition);

    return GoogleMap(
        myLocationEnabled: true,
        markers: _markers,
        initialCameraPosition: initialLocation,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        scrollGesturesEnabled: true,
        compassEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          setState(() {
            _markers.add(Marker(
                markerId: MarkerId('pin0000001'),
                position: pinPosition,
                icon: pinLocationIcon));
          });
        });
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}

class KakaoMap extends StatefulWidget {
  final String query;

  @override
  _KakaoMapState createState() => _KakaoMapState();

  KakaoMap({required this.query});
}

class _KakaoMapState extends State<KakaoMap> {
  KakaoMap get widget => super.widget;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebView(
          initialUrl: "https://m.map.kakao.com/actions/searchView?q=" +
              widget.query +
              "&wxEnc=MPPQNM&wyEnc=QOPURON&lvl=4",
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
