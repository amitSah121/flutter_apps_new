import 'package:flutter/material.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helper_classes/helperClasses.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/helpers_funcs/misselenious.dart';
import 'package:map_test_1/mapscreen/mapscreen.dart';
import 'package:map_test_1/provider/provider.dart';
import 'package:provider/provider.dart';

class TracerHome extends StatefulWidget {
  const TracerHome({super.key});

  @override
  State<TracerHome> createState() => _TracerHomeState();
}

class _TracerHomeState extends State<TracerHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var result = 'Search...';
  var map = MapScreen();
  Journey? searchResult;
  bool openRightDrawer = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final myModel = Provider.of<CustomProvider>(context, listen: false);
    final args = myModel.currentJourney;
    if(args != null){
      searchResult = args;
      result = searchResult!.metadata.split(";")[0].split("=")[1];
      map.pathNodes = searchResult!.pathNodes;
      map.pageNodes = searchResult!.pageNodes;
      map.mediaNodes = searchResult!.mediaNodes;
      map.goMyLoc = false;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: appBarWidget(context),
      drawer: appDrawer(),
      body: Stack(children: [
        map,
        Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: ListTile(
            leading: result == "Search..."
                ? const Icon(Icons.search)
                : const Icon(Icons.edit),
            title: Text(result),
            onTap: () {
              Navigator.pushNamed(context, "/search");
            },
          ),
        ),
        if (searchResult != null && openRightDrawer) // this is to implement altitude
        Positioned(
          right: 0,
          top: 100,
          child:  Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(16))),
            width: noteDisplaySize[0],
            height: MediaQuery.of(context).size.height*0.5,
            child: ListView.builder(
              itemCount: map.pageNodes!.length+map.mediaNodes!.length,
              itemBuilder: (context,index){
                return (index < map.pageNodes!.length) ? 
                ListTile(
                  title: const Text("Pages"),
                  leading: const Icon(Icons.book),
                  onTap: (){
                    Navigator.pushNamed(context,"/pageEditor",arguments: map.pageNodes![index]);
                  },
                )
                :
                ListTile(
                  title: const Text("Media"),
                  leading: const Icon(Icons.photo),
                  onTap: (){
                    Navigator.pushNamed(context,"/mediaEditor",arguments: map.mediaNodes![index - map.pageNodes!.length]);
                  },
                )
                ; 
              }),
          ),
        ),
        if(!openRightDrawer && searchResult != null)
        Positioned(
          right: 0,
          top: 100,
          child:  Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(16)), border: Border(left: BorderSide(color: Colors.black,width: 3),)),
            width: noteDisplaySize[1],
            height: MediaQuery.of(context).size.height*0.5,
          )
        ),
        if (searchResult != null) // this is to implement altitude
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        height: 64,
                        width: MediaQuery.of(context).size.width,
                        child: Column(children: [
                          drawAltitude(MediaQuery.of(context).size.width*0.9, 64)// made for having different icons in column
                        ]))
                  ],
                )),
          ),
      ]),
      floatingActionButton: floatingActionWidget(),
      bottomNavigationBar: bottomBarDraw(),
    );
  }

  CustomPaint drawAltitude(double width, double height) {
    List<double> xes = generateEvenlySpaced(0, width, searchResult!.pathNodes.length);
    int i=-1;
    List<Offset> offsets = searchResult!.pathNodes.map((p){
      i++;
      return Offset(xes[i], p.altitude);
    }).toList();
    return CustomPaint(
      size: Size(width, height), // Define the size of the canvas
      painter: LinePainter(
        offsets
      ), 
      );
  }

  AppBar appBarWidget(BuildContext context) {
    return AppBar(
      title: const Text(appname),
      leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu)),
      actions: [
        IconButton(
          onPressed: () {
            Future.microtask(() async {
              try {
              } catch (e) {
                print(e);
              }
            });

            // Navigator.pushNamed(context, "/notifications");
          },
          icon: const Icon(Icons.notifications)),
        IconButton(
          onPressed: (){
            createPageMediaNode(context);
          }, 
          icon: const Icon(Icons.add)
        )  
      ],
    );
  }


  Drawer appDrawer() {
    var keys = drawerConstHome.keys.toList();
    return Drawer(
        child: ListView.builder(
            itemCount: keys.length,
            itemBuilder: (ctx, index) {
              return drawerElement(
                  label: keys[index],
                  press: () {
                    drawerElementFuncs(index);
                  },
                  icon: Icon(drawerConstHome[keys[index]]));
            }));
  }

  void drawerElementFuncs(index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, "/journey_notes");
        break;
      case 1:
        Navigator.pushNamed(context, "/settings");
        break;
    }
  }

  ListTile drawerElement(
      {required label, required VoidCallback press, required icon}) {
    return ListTile(
      leading: icon,
      title: TextButton(
        onPressed: press,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(label),
        ),
      ),
    );
  }

  Padding floatingActionWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 56),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(24))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                
              },
              icon: const Icon(Icons.assistant_navigation),
              iconSize: 48,
            ),
            if(searchResult != null)
            IconButton(
              onPressed: (){
                openRightDrawer = !openRightDrawer;
                setState(() {
                  
                });
              }, 
              icon: Icon(!openRightDrawer ? Icons.menu_open : Icons.close),
              iconSize: 36,
            )
          ],
        ),
      ),
    );
  }

  BottomNavigationBar bottomBarDraw() {
    var keys = bottomNavBarTracerHome.keys.toList();
    bool isTracedDone = searchResult!.metadata.split(";")[1].split("=")[1] == "true";
    final which2 = !isTracedDone ? 0 : 1;
    return BottomNavigationBar(
      items: keys.map((ele) {
        return bottomNavBarTracerHome[ele].runtimeType == ([Icons.all_out]).runtimeType ?
        BottomNavigationBarItem(
          icon: Icon((bottomNavBarTracerHome[ele]! as List<IconData>)[which2]),
          label: ele.split("/")[which2],
        )
        :
        BottomNavigationBarItem(
          icon: Icon(bottomNavBarTracerHome[ele] as IconData),
          label: ele,
        );
      }).toList(),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      onTap: (index) {
        bottomBarElementFuncs(index,which2);
      },
    );
  }

  void bottomBarElementFuncs(index, which2) {
    switch (index) {
      case 0:
        if(which2 == 0){
          final myModel = Provider.of<CustomProvider>(context, listen: false);
          myModel.currentJourney = null;
        }else if(which2 == 1){

        }
        break;
      case 1:
        break;
      case 2:
        Navigator.pop(context);
        break;
    }
  }
}
