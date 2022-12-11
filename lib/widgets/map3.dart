import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:gridlocator/gridlocator.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 0;
var SOURCE_LOCATION = LatLng(37.35233177989831, 127.3421918417353);
const LatLng DEST_LOCATION = LatLng(37.335685, -122.0605916);

class ThemaMap extends StatefulWidget {
  final dynamic query;

  @override
  State<ThemaMap> createState() => ThemaMapState();

  ThemaMap({this.query});
}

class ThemaMapState extends State<ThemaMap> {
  final GlobalKey scaffoldKey = GlobalKey();
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  List<Marker> customMarkers = [];
// for my drawn routes on the map
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
//String googleAPIKey = “<YOUR_API_KEY>”;
// for my custom marker pins
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
// the user's initial location and current location
// as it moves
  late Position currentPosition;
  late Position lastPosition;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  void initState() {
    super.initState();
    //setCustomMapPin();

    getPosition().then((value) => {updatePinOnMap()});

    // subscribe to changes in the user's location
    // by "listening" to the location's onLocationChanged event

    // showPinsOnMap();
    // set custom marker pins
  }

  Future<void> getPosition() async {
    /*
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    lastPosition = (await Geolocator.getLastKnownPosition(
        forceAndroidLocationManager: true))!;
    print(currentPosition);
    print(lastPosition);
    print(currentPosition.latitude.toString() +
        " " +
        currentPosition.longitude.toString());
*/
    final currentPosition = Gridlocator.decode('GF15vc');
  }

  void updatePinOnMap() async {
    CameraPosition cPosition;
    final m = Gridlocator.decode('GF15vc');
    if (widget.query != null) {
      cPosition = CameraPosition(
          target: LatLng(m.longitude, m.latitude),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    } else {
      cPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
      );
    }

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {
      // updated position
      var pinPosition =
          LatLng(currentPosition.latitude, currentPosition.longitude);

      customMarkers.removeWhere((m) => m.markerId.value == 'sourcePin');
      customMarkers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: pinPosition, // updated position
          icon: BitmapDescriptor.defaultMarker));
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: SOURCE_LOCATION);

    initialCameraPosition = CameraPosition(
        target: LatLng(37.3595316, 127.1052133),
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
              myLocationEnabled: true,
              markers: Set<Marker>.of(markers.values),
              initialCameraPosition: initialCameraPosition,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              compassEnabled: true,

              //compassEnabled: true,
              tiltGesturesEnabled: false,
              //markers: _markers,
              //   polylines: _polylines,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onCameraMove: (CameraPosition position) {
                showPinsOnMap3(position);
              })
        ],
      ),
    );
  }

  int i = 0;
  Future<void> showPinsOnMap3(CameraPosition currentPosition) async {
    if (currentPosition.zoom > 12) {
      final m = Gridlocator.decode('GF15vc');

      NetworkHelper(Uri.parse('http://luckytransportca.cafe24.com/GET_SGLIST/' +
              m.longitude.toString() +
              "/" +
              m.latitude.toString()))
          .getData()
          .then((value) => {
                setState(() {
                  markers.clear();
                  value.forEach((x) {
                    BitmapDescriptor bitmapDescriptor =
                        BitmapDescriptor.defaultMarker;

                    if (widget.query != null) {
                      if (x['seq_no'] == widget.query['seq_no']) {
                        bitmapDescriptor =
                            BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueAzure);
                      } else {
                        bitmapDescriptor =
                            BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueYellow);
                      }
                    }

/*
                    bitmapDescriptor = await BitmapDescriptor.fromAssetImage(
                        ImageConfiguration(devicePixelRatio: 1.5),
                        "images/profile.png");
*/

                    var markerIdVal = x['gio_x'].toString();
                    final MarkerId markerId = MarkerId(markerIdVal);

                    markers[MarkerId(markerIdVal + "a")] = Marker(
                        markerId: MarkerId(markerIdVal + "a"),
                        position: LatLng(m.longitude, m.latitude),
                        // consumeTapEvents: true,
                        visible: true,
                        infoWindow: InfoWindow(
                          title: x['bizname'],
                          snippet: "click me",
                          onTap: () {
                            print("Marker tapped");

                            showModalBottomSheet<void>(
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                    height: 400,
                                    color: Colors.amber.withOpacity(0.1),
                                    child: getBottomSheet("17.4435, 78.3772")
                                    /*
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const Text('Modal BottomSheet'),
                                      ElevatedButton(
                                        child: const Text('Close BottomSheet'),
                                        onPressed: () => Navigator.pop(context),
                                      )
                                    ],
                                  ),
                                ),

                                */
                                    );
                              },
                            );
                          },
                        ),
                        icon: bitmapDescriptor);
                  });
                }),
              });
      //  });
    }
  }

  Future<BitmapDescriptor> createCustomMarkerBitmap(String title) async {
    TextSpan span = new TextSpan(
      style: new TextStyle(
        color: Colors.black,
        /*
            color: Theme.of(context).textTheme== 'Dark'
                ? Colors.white
                : Colors.black,
            fontSize: 35.0,
            fontWeight: FontWeight.bold,
            */
      ),
      text: title,
    );

    TextPainter tp = new TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.text = TextSpan(
      text: title,
      style: TextStyle(
        fontSize: 35.0,
        color: Theme.of(context).accentColor,
        letterSpacing: 1.0,
        fontFamily: 'Roboto Bold',
      ),
    );

    PictureRecorder recorder = new PictureRecorder();
    Canvas c = new Canvas(recorder);

    tp.layout();
    tp.paint(c, new Offset(20.0, 10.0));

    /* Do your painting of the custom icon here, including drawing text, shapes, etc. */

    Picture p = recorder.endRecording();
    ByteData? pngBytes =
        await (await p.toImage(tp.width.toInt() + 40, tp.height.toInt() + 20))
            .toByteData(format: ImageByteFormat.png);

    Uint8List data = Uint8List.view(pngBytes!.buffer);

    return BitmapDescriptor.fromBytes(data);
  }
}

class NetworkHelper {
  NetworkHelper(this.url);

  Uri url;

  Future getData() async {
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }
}

Widget getBottomSheet3(String s) {
  return Stack(
    children: [
      Container(
        margin: EdgeInsets.only(top: 32),
        color: Colors.white,
        child: Column(
          children: [
            Container(
              color: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hytech City Public School \n CBSC",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text("4.5",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text("970 Folowers",
                            style: TextStyle(color: Colors.white, fontSize: 14))
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Memorial Park",
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Icon(
                  Icons.map,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 20,
                ),
                Text("$s")
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Icon(
                  Icons.call,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 20,
                ),
                Text("040-123456")
              ],
            )
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topRight,
          child: FloatingActionButton(
              child: Icon(Icons.navigation), onPressed: () {}),
        ),
      )
    ],
  );
}

Widget getBottomSheet(String s) {
  return Stack(
    children: [
      Container(
        margin: EdgeInsets.only(top: 32),
        color: Colors.white,
        child: Column(
          children: [
            Container(
              color: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hytech City Public School \n CBSC",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text("4.5",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text("970 Folowers",
                            style: TextStyle(color: Colors.white, fontSize: 14))
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Memorial Park",
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Icon(
                  Icons.map,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 20,
                ),
                Text("$s")
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Icon(
                  Icons.call,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 20,
                ),
                Text("040-123456")
              ],
            )
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topRight,
          child: FloatingActionButton(
              child: Icon(Icons.navigation), onPressed: () {}),
        ),
      )
    ],
  );
}
