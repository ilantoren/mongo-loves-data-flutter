import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logging/logging.dart';
import 'package:map_flutter/cuisine.dart';
import 'package:map_flutter/realm_neighborhood.dart';

import 'realm_neighborhood.dart' as realm;

Future main() async {
  // load env
  await dotenv.load(fileName: ".env");

  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // prints message to console
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  // API key for Google Maps is not part of the checked in code
  log.info('value of maps api key is ${dotenv.env['MAPS_API_KEY']}');
  final String? _host = dotenv.env['HOST'];
  if (_host == null) {
    log.info("no value for host returned from .env");
  } else {
    log.info('Url host is $_host');
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> cuisineListKey = GlobalKey<ScaffoldState>() ;

  // array of  true/false that reflects the state of the drawer tilelist view
  final List<bool> selectedCuisines = List.filled(200, true);
  List<String> currentSelection = [];

  final List<Place> _items = [];


  late final List<String> _cuisineList;
  final Map<PolygonId, Polygon> _polygons = <PolygonId, Polygon>{};
  final Set<Marker> _markers = {};
  GoogleMapController? mapController;
  late final ClusterManager<Place> _clusterManager;

  List<String> _neighborhoods = [];
  final log = Logger("map_flutter");
  String _neighborhood = "";
  set clusterId(String clusterId) {}
  Future<Marker> Function(Cluster<Place>) get _markerBuilder =>
      (cluster) async {
        int cnt = cluster.items.length;
        String label;
        if (cnt > 2) {
          label = "$cnt restaurants";
        } else if (cnt == 2) {
          label = cluster.items.first.name + '\n' + cluster.items.last.name;
        } else {
          label = cluster.items.first.name;
        }
        return Marker(
          markerId: MarkerId(cluster.getId()),
          infoWindow: InfoWindow(title: label),
          position: cluster.location,
          onTap: () {
            log.info( cluster.getId() );
            focusOnMarker( cluster.location );
          },
          icon: await _getMarkerBitmap(cluster.isMultiple ? 125 : 75,
              text: cluster.isMultiple ? cluster.count.toString() : null),
        );
      };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }
              return _neighborhoods.where((String option) {
                return option.contains(textEditingValue.text);
              });
            },
            onSelected: _callRealmFunction,
            initialValue: const TextEditingValue(),
          ),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: LatLng(40.764, -73.971),
            zoom: 13,
          ),
          markers: _markers,
          polygons: _polygons.values.toSet(),
          onCameraMove: _clusterManager.onCameraMove,
          onCameraIdle: _clusterManager.updateMap,
        ),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: false,
                leadingWidth: 30,
                flexibleSpace: const FlexibleSpaceBar(
                  title: Text("Restaurant cuisines"),
                  background: FlutterLogo(),
                ),
                expandedHeight: 160,
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.clear_all) ,
                    tooltip: 'Clear all',
                    onPressed: _clearAllCuisineSelections,
                  ),
                  IconButton(
                    icon: const Icon(Icons.done),
                    tooltip: 'Close',
                    onPressed: _closeDrawer,
                  )
                ],
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                    height: 50,
                    child: Center(
                        child: Text(
                            "Select which cuisines to include, \nexclude, ALL, or RESET"))),
              ),
              SliverList(
                key: cuisineListKey,
                // Use a delegate to build items as they're scrolled on screen.
                delegate: SliverChildBuilderDelegate(
                  // The builder function returns a ListTile with a title that
                  // displays the index of the current item.
                  (context, index) =>
                      SwitchListTile(title: Text(_cuisineList[index]), tileColor: Colors.white54, value: selectedCuisines[index],
                        selectedTileColor: Colors.lightBlueAccent,
                        onChanged: (bool value) {
                             setState( () {
                                selectedCuisines[index]  = value;
                             });
                        },
                      ),
                  // Builds 1000 ListTiles
                  childCount: _cuisineList.length,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: OverflowBar(
                    alignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextButton(
                              onPressed: _selectAllCuisines,
                              child: const Text(("ALL"))),
                          TextButton(
                              onPressed: _editCuisineList,
                              child: const Text("Edit List")),
                        ],
                      )
                    ]))),
      ),
    );
  }
  Polygon? createPolygon(List<LatLng>? coordinates) {
    if (coordinates != null) {
      return Polygon(
          polygonId: const PolygonId('region'),
          consumeTapEvents: true,
          strokeColor: Colors.orange,
          strokeWidth: 5,
          fillColor: Colors.transparent,
          points: coordinates);
    }
    return null;
  }

  final  maxAutoZoom = 17.0;
  Future<double> Function() get zoomLevel  => ()  async {
   double x = await  mapController!.getZoomLevel();
    log.info( "Current zoom level is $x");
        if( x > maxAutoZoom) {
          return x;
        }
        else
          {
           return  min(x += 1, 17);
          }
  };


  void focusOnMarker(LatLng location) async {
    zoomLevel().then((zl) => {

              mapController?.moveCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: location, zoom: zl)))

        });
  }

  @override
  void initState() {
    _initNeighborhoods();
    List<String> cuisineList = [];
    getRestaurantTypes('5').then((x) => {
          if (x != null)
            {
              for (var i in x) {cuisineList.add(i!)}
            }
        });
    for (var i in cuisineList) {
      log.info(i);
    }
    _cuisineList = cuisineList;
    _clusterManager = _initClusterManager();
    super.initState();
  }

  /*
       Bring the focus of GM to the  marker and zoom in
   */
  regionBoundary(List<double>? _latitude, List<double>? _longitude) {
    // default data for NYC
    double west = 40.533;
    double east = 40.93;
    double north = -73.665;
    double south = -74.337;
    if (_latitude != null) {
      _latitude.sort();
      south = _latitude.first;
      north = _latitude.last;
    }
    if (_longitude != null) {
      _longitude.sort();
      west = _longitude.first;
      east = _longitude.last;
    }
    LatLng southwest = LatLng(south, west);
    LatLng northeast = LatLng(north, east);
    log.info("southwest: " + southwest.toString());
    log.info("northeast: " + northeast.toString());
    return LatLngBounds(southwest: southwest, northeast: northeast);
  }


  Future<void> _callRealmFunction(String selection) async {
    setState(() {
      log.info("_callRealm  $selection");
      _neighborhood = selection;
    });
    _realmFunction();
  }



  void _clearAllCuisineSelections() {
    setState(() {
      selectedCuisines.fillRange( 0,199, false);
    });
 }

  Future<void> _closeDrawer() async {
    _scaffoldKey.currentState?.openEndDrawer();
    log.info( "close drawer");
    mapController
        ?.moveCamera(CameraUpdate.newCameraPosition(const CameraPosition(
      target: LatLng(40.764, -73.971),
      zoom: 13,
    )));
    _displayedCuisines();
  }

  Future<void> _displayedCuisines() async {
    List<String> selected = [];
    int index = 0;
    bool allSelected = true;
    currentSelection.clear();
    for ( var i in _cuisineList ) {
      if ( selectedCuisines[index ] ) {
        selected.add( i );
      }else {
        allSelected = false;
      }
      index++;
    }
    if ( ! allSelected ) {
      currentSelection.addAll( selected );
      log.info ( selected);
    }
  }

  Future<void> _editCuisineList() async {
    log.info("Edit the list");
    _openDrawer();
  }

  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
    if (kIsWeb) size = (size / 2).floor();

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.orange;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  // populate the choices for the Autocomplete
  ClusterManager<Place> _initClusterManager() {
    return ClusterManager<Place>(_items, _updateMarkers,
        markerBuilder: _markerBuilder);
  }

  Future _initNeighborhoods() async {
    final data = rootBundle.loadString('assets/neighborhoods.txt');
    final neighborhoods = await data;
    setState(() {
      _neighborhoods = neighborhoods.split('\n');
    });
    return true;
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
      mapController = controller;
      _clusterManager.setMapId(controller.mapId);
      _neighborhood = "Upper West Side";
      _realmFunction();
    });
  }


  Future<void> _openDrawer() async {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _realmFunction() async {
    _displayedCuisines();
    final realm.Realm_neighborhood data =
        await realm.getRealmNeighborhood(_neighborhood, currentSelection);
    Iterable<LatLng>? points;
    //  Call to realm returns nullable collection of points the  data.coord != null makes that collection safe to use
    if (data.coord != null) {
      points = data.coord
          ?.map((a) => LatLng(a.lat as double, a.lng as double))
          .cast<LatLng>();
    }
    LatLngBounds bounds = regionBoundary(data.lat, data.long);
    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 0);
    final polygon = createPolygon(points?.toList());
    mapController?.moveCamera(cameraUpdate);
    setState(() {
      _polygons.clear();
      if (polygon != null) {
        _polygons[const PolygonId("region")] = polygon;
      }
      if (data.restaurants != null) {
        List<Restaurants> restaurants = data.restaurants as List<Restaurants>;
        _refreshMarkers(restaurants);
      }
    });
    log.info("Neighborhood found  ${data.name}");
  }

  void _refreshMarkers(List<Restaurants> restaurants) {
    _items.clear();
    for (Restaurants x in restaurants) {
      String label = "${x.name}:  ${x.cuisine}";
      LatLng? latLng = x.address?.toLatLng();
      if (latLng != null) {
        final Place place = Place(name: label, latLng: latLng);
        _items.add(place);
      } else {
        log.info("$label was not valid");
      }
    }
  }


 Future<void> _selectAllCuisines() async {
    log.info("SET ALL CUISINE AS SELECTED");
    setState( () {
      selectedCuisines.fillRange(0, 199, true);
      _displayedCuisines();
    });
  }
  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      _markers.clear();
      _markers.addAll(markers);
    });
  }
}
