import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oilstock/views/image_view.dart';
import 'package:oilstock/views/oil_home.dart';
import 'package:oilstock/views/ship_main.dart';
import 'package:oilstock/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:proj4dart/proj4dart.dart';
import '../widgets/map3.dart';
import '../widgets/map4.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;
import 'package:label_marker/label_marker.dart';

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

class OrderMain extends StatefulWidget {
  final token;
  final user_id;
  const OrderMain(this.token, this.user_id, {Key? key}) : super(key: key);

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

Future<Position> getCurrentLocation() async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  return position;
}

var currPosition = null;
Future<Position> currPo = getCurrentLocation();

class _WebViewExampleState extends State<OrderMain> {
  late WebViewController _controller;
  final double _initFabHeight = 220.0;
  double _fabHeight = 500;
  double _panelHeightOpen = 500;
  double _panelHeightClosed = 150.0;
  late Map4 map;
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    _fabHeight = _initFabHeight;
    currPo.then((value) => {
          setState(() {
            currPosition = value;
            googleMapInit();
          })
        });
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OIL STOCK'),
        leading: CircleAvatar(
            maxRadius: 50.0,
            backgroundImage: AssetImage('assets/icon/launcher_icon_main.png')),

        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        //  actions: <Widget>[
        //  NavigationControls(_controller.future),
        //   SampleMenu(_controller.future),
        //  ],
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

        var document = [];

        return Stack(
          children: <Widget>[
            Center(
                child: WillPopScope(
                    onWillPop: () => _goBack(context),
                    child: (currPosition != null)
                        ? GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(pointSrc.y, pointSrc.x),
                              zoom: 15,
                            ),
                            markers: markers,
                          )
                        : Text("로딩중...."))),
            SlidingUpPanel(
              maxHeight: _panelHeightOpen,
              minHeight: _panelHeightClosed,
              parallaxEnabled: true,
              parallaxOffset: .5,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: Radius.circular(18.0)),
              onPanelSlide: (double pos) => setState(() {
                _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                    _initFabHeight;
              }),
              panelBuilder: (sc) => _panel(sc),
            ),
            // the fab

            Positioned(
              right: 20.0,
              bottom: _fabHeight,
              child: FloatingActionButton(
                child: Icon(
                  Icons.gps_fixed,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {},
                backgroundColor: Colors.white,
              ),
            ),

            Positioned(
                top: 0,
                child: ClipRRect(
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).padding.top,
                          color: Colors.transparent,
                        )))),

            //the SlidingUpPanel Title
            Positioned(
                right: 20.0,
                width: MediaQuery.of(context).size.width - 40,
                top: 20.0,
                child: TextField(
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true, //<-- SEE HERE
                      fillColor: Colors.white,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color.fromARGB(255, 10, 10, 10),
                      ),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.black)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          borderSide:
                              BorderSide(width: 1, color: Colors.black)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        borderSide: BorderSide(width: 1, color: Colors.black),
                      ),
                    ))),
          ],
        );
      }),
    );
  }

  Point pointForward = new Point(x: 0, y: 0);
  //var pointSrc = Point(x: 314996.15900, y: 544938.50758);
  late Point pointSrc = new Point(x: 0, y: 0);
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

  void googleMapInit() {
    pointSrc = Point(x: currPosition.longitude, y: currPosition.latitude);
    pointForward = projSrc.transform(projDst, pointSrc);
    getData();
  }

  Future getData() async {
    var url =
        'http://www.opinet.co.kr/api/aroundAll.do?code=F221206442&x=${pointForward.x}&y=${pointForward.y}&radius=5000&sort=1&prodcd=B027&out=json';
    http.Response response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    var list = data['RESULT'];

    return list;
  }

  Set<Marker> markers = {};
  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    final googleOffices = await getData();

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
  }

  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                DropdownButton<String?>(
                  style: TextStyle(color: Color.fromARGB(255, 4, 4, 4)),
                  onChanged: (String? newValue) {
                    print(newValue);
                    setState(() {
                      if (mapController != null)
                        mapController.animateCamera(CameraUpdate.newLatLngZoom(
                            LatLng(
                                currPosition.latitude, currPosition.longitude),
                            14));
                    });
                  },
                  items: [null, 'M', 'F']
                      .map<DropdownMenuItem<String?>>((String? i) {
                    return DropdownMenuItem<String?>(
                      value: i,
                      child:
                          Text({'M': '반경 3KM', 'F': '반경 3KM'}[i] ?? '반경 3KM'),
                    );
                  }).toList(),
                ),
                DropdownButton<String?>(
                  style: TextStyle(color: Color.fromARGB(255, 6, 6, 6)),
                  onChanged: (String? newValue) {
                    print(newValue);
                    setState(() {
                      if (mapController != null)
                        mapController.animateCamera(CameraUpdate.newLatLngZoom(
                            LatLng(
                                currPosition.latitude, currPosition.longitude),
                            14));
                    });
                  },
                  items: [null, 'M', 'F']
                      .map<DropdownMenuItem<String?>>((String? i) {
                    return DropdownMenuItem<String?>(
                      value: i,
                      child: Text({'M': '평가순', 'F': '거리순'}[i] ?? '가격순'),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(
              height: 36.0,
            ),
            Container(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Images",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(
                    height: 12.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl:
                            "https://images.fineartamerica.com/images-medium-large-5/new-pittsburgh-emmanuel-panagiotakis.jpg",
                        height: 120.0,
                        width: (MediaQuery.of(context).size.width - 48) / 2 - 2,
                        fit: BoxFit.cover,
                      ),
                      CachedNetworkImage(
                        imageUrl:
                            "https://cdn.pixabay.com/photo/2016/08/11/23/48/pnc-park-1587285_1280.jpg",
                        width: (MediaQuery.of(context).size.width - 48) / 2 - 2,
                        height: 120.0,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 36.0,
            ),
            Container(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("About",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(
                    height: 12.0,
                  ),
                  Text(
                    """Pittsburgh is a city in the state of Pennsylvania in the United States, and is the county seat of Allegheny County. A population of about 302,407 (2018) residents live within the city limits, making it the 66th-largest city in the U.S. The metropolitan population of 2,324,743 is the largest in both the Ohio Valley and Appalachia, the second-largest in Pennsylvania (behind Philadelphia), and the 27th-largest in the U.S.\n\nPittsburgh is located in the southwest of the state, at the confluence of the Allegheny, Monongahela, and Ohio rivers. Pittsburgh is known both as "the Steel City" for its more than 300 steel-related businesses and as the "City of Bridges" for its 446 bridges. The city features 30 skyscrapers, two inclined railways, a pre-revolutionary fortification and the Point State Park at the confluence of the rivers. The city developed as a vital link of the Atlantic coast and Midwest, as the mineral-rich Allegheny Mountains made the area coveted by the French and British empires, Virginians, Whiskey Rebels, and Civil War raiders.\n\nAside from steel, Pittsburgh has led in manufacturing of aluminum, glass, shipbuilding, petroleum, foods, sports, transportation, computing, autos, and electronics. For part of the 20th century, Pittsburgh was behind only New York City and Chicago in corporate headquarters employment; it had the most U.S. stockholders per capita. Deindustrialization in the 1970s and 80s laid off area blue-collar workers as steel and other heavy industries declined, and thousands of downtown white-collar workers also lost jobs when several Pittsburgh-based companies moved out. The population dropped from a peak of 675,000 in 1950 to 370,000 in 1990. However, this rich industrial history left the area with renowned museums, medical centers, parks, research centers, and a diverse cultural district.\n\nAfter the deindustrialization of the mid-20th century, Pittsburgh has transformed into a hub for the health care, education, and technology industries. Pittsburgh is a leader in the health care sector as the home to large medical providers such as University of Pittsburgh Medical Center (UPMC). The area is home to 68 colleges and universities, including research and development leaders Carnegie Mellon University and the University of Pittsburgh. Google, Apple Inc., Bosch, Facebook, Uber, Nokia, Autodesk, Amazon, Microsoft and IBM are among 1,600 technology firms generating \$20.7 billion in annual Pittsburgh payrolls. The area has served as the long-time federal agency headquarters for cyber defense, software engineering, robotics, energy research and the nuclear navy. The nation's eighth-largest bank, eight Fortune 500 companies, and six of the top 300 U.S. law firms make their global headquarters in the area, while RAND Corporation (RAND), BNY Mellon, Nova, FedEx, Bayer, and the National Institute for Occupational Safety and Health (NIOSH) have regional bases that helped Pittsburgh become the sixth-best area for U.S. job growth.
                  """,
                    softWrap: true,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 24,
            ),
          ],
        ));
  }

  Widget _button(String label, IconData icon, Color color) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Icon(
            icon,
            color: Colors.white,
          ),
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.15),
              blurRadius: 8.0,
            )
          ]),
        ),
        SizedBox(
          height: 12.0,
        ),
        Text(label),
      ],
    );
  }
}
