import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../bloc.navigation_bloc/navigation_bloc.dart';
import 'package:firebase_database/firebase_database.dart';

class InfoPage extends StatelessWidget with NavigationStates {

  final DatabaseReference databaseReference1 = FirebaseDatabase.instance.reference().child("DriveAvailable");

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData.dark(),
        home: Home(),
      );
    }

  
}
class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}


class HomeState extends State<Home> {
  List<DriveAvailable> driveAvailables = List();
  DriveAvailable driveAvailable;
  DatabaseReference driveAvailableRef;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    driveAvailable = DriveAvailable(0,0);
    final FirebaseDatabase database = FirebaseDatabase.instance; //Rather then just writing FirebaseDatabase(), get the instance.  
    driveAvailableRef = database.reference().child('DriveAvailable');
    driveAvailableRef.onChildAdded.listen(_onEntryAdded);
    driveAvailableRef.onChildChanged.listen(_onEntryChanged);
  }

  _onEntryAdded(Event event) {
    setState(() {
      driveAvailables.add(DriveAvailable.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var old = driveAvailables.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      driveAvailables[driveAvailables.indexOf(old)] = DriveAvailable.fromSnapshot(event.snapshot);
    });
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      driveAvailableRef.push().set(driveAvailable.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FB example'),
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 0,
            child: Center(
              child: Form(
                key: formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.info),
                      title: TextFormField(
                        initialValue: "",
                        onSaved: (val) => driveAvailable.lat = double.parse(val),
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.info),
                      title: TextFormField(
                        initialValue: '',
                        onSaved: (val) => driveAvailable.lon = double.parse(val),
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        handleSubmit();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            child: FirebaseAnimatedList(
              query: driveAvailableRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return new ListTile(
                  leading: Icon(Icons.message),
                  title:Text(driveAvailables[index].lat.toString()),
                  subtitle: Text(driveAvailables[index].lon.toString()),
                );
              },
            ),
          ),
        ],
      ),
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