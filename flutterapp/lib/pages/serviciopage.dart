import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../bloc.navigation_bloc/navigation_bloc.dart';
import 'package:firebase_database/firebase_database.dart';


class ServicioPage extends StatelessWidget with NavigationStates { 
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'DRIVER DEMO'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Set<Marker> unidades = Set();
  List<Marker> unidades_Test = List();
  Circle circle;
  GoogleMapController _controller;
  List<DriveAvailable> driveAvailables = List();
  DriveAvailable driveAvailable;
  DatabaseReference driveAvailableRef;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ByteData byteData ;
  
  @override
  void initState(){
    super.initState();
    driveAvailable = DriveAvailable(0,0);
    final FirebaseDatabase database = FirebaseDatabase.instance; //Rather then just writing FirebaseDatabase(), get the instance.  
    driveAvailableRef = database.reference().child('DriveAvailable');
    driveAvailableRef.onChildAdded.listen(_onEntryAdded);
    driveAvailableRef.onChildChanged.listen(_onEntryChanged);
    driveAvailableRef.onChildRemoved.listen(_onEntryRemove);
  }
  _onEntryRemove(Event event){
    DriveAvailable d = DriveAvailable.fromSnapshot(event.snapshot);
      unidades.removeWhere((item)=>item.markerId.value == d.key);
      driveAvailables.removeWhere((item)=>item.key == d.key);
  }
  _onEntryAdded(Event event)async {
    Uint8List markerIcon = await getMarker("assets/car_icon.png");
    setState(() {
      DriveAvailable d = DriveAvailable.fromSnapshot(event.snapshot);     
      LatLng latlng = LatLng(d.lat, d.lon);   
   /*   unidades.add( new Marker(
        markerId: MarkerId(d.key.toString()),
        position: latlng,
        icon: BitmapDescriptor.fromBytes(markerIcon),
        draggable: false,
        flat: true,
        anchor: Offset(0.5, 0.5)
      ));*/
      unidades_Test.add(new Marker(
        markerId: MarkerId(d.key.toString()),
        position: latlng,
        icon: BitmapDescriptor.fromBytes(markerIcon),
        draggable: false,
        flat: true,
        anchor: Offset(0.5, 0.5)
      ));
      driveAvailables.add(DriveAvailable.fromSnapshot(event.snapshot));   
    });
  }
//actualizar
  var old,old1;
  _onEntryChanged(Event event) async {
    Uint8List markerIcon = await getMarker("assets/car_icon.png");
    old = driveAvailables.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    old1 = unidades.singleWhere((entry) {
      return entry.markerId.value == event.snapshot.key;
    });
    setState(() {
      //unidades.indexWhere(in=> in == 2);
      //old=unidades.indexOf(old1);
      DriveAvailable d1 = DriveAvailable.fromSnapshot(event.snapshot);
      LatLng latlng = LatLng(d1.lat, d1.lon);
      //unidades[]=unidades.where((f)=>f.markerId.value == old ).elementAt(0).copyWith(positionParam: latlng);
      unidades_Test[unidades_Test.indexOf(old1)] = new Marker(
	        markerId: MarkerId(d1.key.toString()),
          icon: BitmapDescriptor.fromBytes(markerIcon),
	        position: latlng,
	        draggable: false,
	        flat: true,
	        anchor: Offset(0.5, 0.5)
      );
      //unidades[old1] = DriveAvailable.fromSnapshot(event.snapshot);
      
      driveAvailables[driveAvailables.indexOf(old)] = DriveAvailable.fromSnapshot(event.snapshot);
    });
  }

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(-16.4064572, -71.5248646),
    zoom: 14.4746,
  );

  Future<Uint8List> getMarker(String path) async {
    ByteData byteData = await DefaultAssetBundle.of(context).load(path);
    ui.Codec codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List(),targetWidth:30);
    ui.FrameInfo fi = await codec.getNextFrame();    
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      circle = Circle(
          circleId: CircleId("customer"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(50));
      unidades.add(new Marker(
        markerId: MarkerId("customerId"),
        zIndex: 2,
        position: latlng,
        icon: BitmapDescriptor.fromBytes(imageData),
        draggable: false,
        flat: true,
        anchor: Offset(0.5, 0.5)
      ));
    });
  }

  void getCurrentLocation() async {
    try {

      Uint8List imageData = await getMarker("assets/location_128.png");
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }


      _locationSubscription = _locationTracker.onLocationChanged().listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(newLocalData.latitude, newLocalData.longitude),
              tilt: 0,
              zoom: 15.00)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialLocation,
        markers: Set.from(unidades_Test),        
        circles: Set.of((circle != null) ? [circle] : []),
        onMapCreated: (GoogleMapController controller) {
          //Completer<GoogleMapController> _controller = new Completer();
          //_controller.complete(controller);
        
          _controller = controller;
          
        },
        

      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.location_searching),
          onPressed: () {
            getCurrentLocation();
          }),
    );
  }
}

class DriveAvailable{
  String key;
  num lat;
  num lon;

  DriveAvailable(this.lat, this.lon);

  DriveAvailable.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        lat = snapshot.value["lat"],
        lon = snapshot.value["lon"];

  toJson() {
    return {
      "lat": lat,
      "lon": lon,
    };
  }
}