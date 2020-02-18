import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../bloc.navigation_bloc/navigation_bloc.dart';
import '../sidebar/menu_item.dart';

class SideBar extends StatefulWidget {
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with SingleTickerProviderStateMixin<SideBar> {
   String currentProfilePic = "https://avatars3.githubusercontent.com/u/16825392?s=460&v=4";
  String otherProfilePic = "https://yt3.ggpht.com/-2_2skU9e2Cw/AAAAAAAAAAI/AAAAAAAAAAA/6NpH9G8NWf4/s900-c-k-no-mo-rj-c0xffffff/photo.jpg";

  void switchAccounts() {
    String picBackup = currentProfilePic;
    this.setState(() {
      currentProfilePic = otherProfilePic;
      otherProfilePic = picBackup;
    });
  }

  AnimationController _animationController;
  StreamController<bool> isSidebarOpenedStreamController;
  Stream<bool> isSidebarOpenedStream;
  StreamSink<bool> isSidebarOpenedSink;
  final _animationDuration = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: _animationDuration);
    isSidebarOpenedStreamController = PublishSubject<bool>();
    isSidebarOpenedStream = isSidebarOpenedStreamController.stream;
    isSidebarOpenedSink = isSidebarOpenedStreamController.sink;
  }

  @override
  void dispose() {
    _animationController.dispose();
    isSidebarOpenedStreamController.close();
    isSidebarOpenedSink.close();
    super.dispose();
  }

  void onIconPressed() {
    final animationStatus = _animationController.status;
    final isAnimationCompleted = animationStatus == AnimationStatus.completed;

    if (isAnimationCompleted) {
      isSidebarOpenedSink.add(false);
      _animationController.reverse();
    } else {
      isSidebarOpenedSink.add(true);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<bool>(
      initialData: false,
      stream: isSidebarOpenedStream,
      builder: (context, isSideBarOpenedAsync) {
        return AnimatedPositioned(
          duration: _animationDuration,
          top: 0,
          bottom: 0,
          left: isSideBarOpenedAsync.data ? 0 : -screenWidth,
          right: isSideBarOpenedAsync.data ? 65 : screenWidth - 35,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  color: const Color(0xFF239B56),
                  child: Column(
                    children: <Widget>[
                      new UserAccountsDrawerHeader(
                        accountEmail: new Text("edwinsaavedra99@gmail.com",style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 12,
                          ),),
                        accountName: new Text("Edwin Saavedra", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),),              
                        decoration: new BoxDecoration(
                          image: new DecorationImage(
                            image: new NetworkImage("https://www.machutravelperu.com/blog/wp-content/uploads/2019/04/arequipa-tourist-attractions-arequipa-city.jpg"),
                            fit: BoxFit.fill
                          )
                        ),
                      ),   
                      new Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: const Color(0xFF239B56),
                        child: Column(
                        children: <Widget>[
                          MenuItem(
                            icon: Icons.drive_eta,
                            title: "Servicio",
                            onTap: () {
                              onIconPressed();
                              BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.ServicioClickedEvent);
                            },
                          ),
                          MenuItem(
                            icon: Icons.person,
                            title: "Mi Perfil",
                            onTap: () {
                              onIconPressed();
                              BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.PerfilClickedEvent);
                            },
                          ),
                          MenuItem(
                            icon: Icons.info,
                            title: "Información",
                            onTap: () {
                              onIconPressed();
                              BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.InfoClickedEvent);
                            },
                          ),
                          Divider(
                            height: 20,
                            thickness: 0.5,
                            color: Colors.white.withOpacity(0.3),
                            indent: 0,
                            endIndent: 0,
                          ),
                          MenuItem(
                            icon: Icons.exit_to_app,
                            title: "Logout",
                          ),
                          
                        ]
                        )
                      ),  
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, -0.9),
                child: GestureDetector(
                  onTap: () {
                    onIconPressed();
                  },
                  child: ClipPath(
                    clipper: CustomMenuClipper(),
                    child: Container(
                      width: 35,
                      height: 110, 
                      color: Color(0xFF000000),
//                      decoration: BoxDecoration(
  //                      image: new DecorationImage(
    //                        image: new NetworkImage("https://www.machutravelperu.com/blog/wp-content/uploads/2019/04/arequipa-tourist-attractions-arequipa-city.jpg"),
      //                      fit: BoxFit.none
        //                ),
          //            ),
                      alignment: Alignment.centerLeft,
                      child: AnimatedIcon(
                        progress: _animationController.view,
                        icon: AnimatedIcons.menu_close,
                        color: Color(0xFFFFFFFF),
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CustomMenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;

    final width = size.width;
    final height = size.height;

    Path path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(0, 8, 10, 16);
    path.quadraticBezierTo(width - 1, height / 2 - 20, width, height / 2);
    path.quadraticBezierTo(width + 1, height / 2 + 20, 10, height - 16);
    path.quadraticBezierTo(0, height - 8, 0, height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}