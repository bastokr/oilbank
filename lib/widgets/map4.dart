import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'locations.dart' as locations;
import 'package:proj4dart/proj4dart.dart';
import 'package:http/http.dart' as http;
import 'package:label_marker/label_marker.dart';

class Map4 extends StatefulWidget {
  final Position currPosition;

  Map4({Key? key, required this.currPosition}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

late Position currPosition2;

class _MyAppState extends State<Map4> {
  Point pointForward = new Point(x: 0, y: 0);
  //var pointSrc = Point(x: 314996.15900, y: 544938.50758);
  late Point pointSrc;
  // Use built-in projection
  Projection projSrc = Projection.get('WGS84') ??
      Projection.add(
        'WGS84',
        '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs',
      );

  // Find Projection by name or define it if not exists
  var projDst = Projection.get('TM128') ??
      Projection.add(
        'TM128',
        '+proj=tmerc +lat_0=38 +lon_0=128 +k=0.9999 +x_0=400000 +y_0=600000 +ellps=bessel +units=m +no_defs +towgs84=-115.80,474.99,674.11,1.16,-2.31,-1.63,6.43',
      );
  @override
  void initState() {
    currPosition2 = widget.currPosition;
    pointSrc = Point(x: currPosition2.longitude, y: currPosition2.latitude);

    pointForward = projSrc.transform(projDst, pointSrc);
    getData();
    super.initState();
  }

  Future getData() async {
    var url =
        'http://www.opinet.co.kr/api/aroundAll.do?code=F221206442&x=${pointForward.x}&y=${pointForward.y}&radius=5000&sort=1&prodcd=B027&out=json';

    var url2 = Uri.parse(url);

    http.Response response = await http.get(url2);

    var data = jsonDecode(response.body);

    var list = data['RESULT'];
    return list;
    print(list);
  }

  Set<Marker> markers = {};
  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    final googleOffices = await getData();
    setState(() async {
      _markers.clear();
      for (final office in googleOffices['OIL']) {
        pointSrc.x = office['GIS_X_COOR'];
        pointSrc.y = office['GIS_Y_COOR'];

        pointForward = projDst.transform(projSrc, pointSrc);

        final marker = Marker(
          markerId: MarkerId(office['OS_NM']),
          icon: await BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(devicePixelRatio: 1),
              'assets/icon/gas-station-location-icon.png'),
          position: LatLng(pointForward.y, pointForward.x),
          infoWindow: InfoWindow(
            title: office['OS_NM'],
            snippet: '가격:' + office['PRICE'].toString(),
          ),
          onTap: () {
            print(office['OS_NM']);
          },
        );

        // markers.add(marker);

        //_markers[office['OS_NM']] = marker;
        markers
            .addLabelMarker(LabelMarker(
          label: office['OS_NM'].toString(),
          icon: await BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(devicePixelRatio: 2.5),
              'assets/icon/gas-station-location-icon.png'),
          markerId: MarkerId(office['OS_NM']),
          position: LatLng(pointForward.y, pointForward.x),
          backgroundColor: Colors.red,
          infoWindow: InfoWindow(
            title: office['OS_NM'],
            snippet: '가격:' + office['PRICE'].toString(),
          ),
        ))
            .then((value) {
          setState(() {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: LatLng(pointSrc.y, pointSrc.x),
        zoom: 15,
      ),
      markers: markers,
    );
  }
}
