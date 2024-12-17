import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helper_classes/helperClasses.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';
import 'package:map_test_1/helpers_funcs/misselenious.dart';
import 'package:map_test_1/mapscreen/mapscreen.dart';
import 'package:map_test_1/provider/provider.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
    final args = ModalRoute.of(context)?.settings.arguments;
    if(args != null){
      searchResult = args as Journey;
      result = searchResult!.name!;
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
                : const Icon(Icons.circle_outlined),
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
    // double minAltitude = searchResult!.pathNodes
    // .map((node) => node.altitude)
    // .reduce((value, element) => value < element ? value : element);
    
    // double maxAltitude = searchResult!.pathNodes
    // .map((node) => node.altitude)
    // .reduce((value, element) => value > element ? value : element);

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
                // await deleteFile("pageNode/2024-12-17 16-25-45.090136");
                // await deleteFile("pageNode/2024-12-17 16-27-44.450202");
                // await deleteFile("pageNode/[fileName, 2024-12-17 16-25-45.090136]");
                // await listFilesDirs(dir: "", pattern: "*/*");
              } catch (e) {
                print(e);
              }
            });

            Navigator.pushNamed(context, "/notifications");
          },
          icon: const Icon(Icons.notifications)),
        IconButton(
          onPressed: (){
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  alignment: Alignment.topRight,
                  title: const Text("Create"),
                  content: SizedBox(
                    width: 40,
                    height: 128,
                    child: ListView(
                      children: [
                        SizedBox(
                          width: 40,
                          child: ListTile(
                            title: const Text("Page"),
                            leading: const Icon(Icons.book),
                            onTap: (){
                              var time = DateTime.now().toString().replaceAll(":", "-");
                              PageNode pageNode = PageNode(
                                rows: RowMap(
                                  rows: {
                                  },
                                ),
                                pathNumber_1: -1, // means not connected to journey
                                pathNumber_2: -1, // means not connected to journey
                                t: 0, 
                                pageNumber: -1, // means not connected to journey
                                metadata: "fileName=$time;title=Untitled;backgroundColor=${Colors.white.value.toString()}",
                              );
                              Future.microtask(()async{
                                await getFile("pageNode/$time");
                                await writeFile("pageNode/$time", jsonEncode(pageNode.toJson()));
                                final myModel = Provider.of<CustomProvider>(context, listen: false);
                                myModel.pageNodes.add(pageNode);
                                Navigator.pushNamed(context, "/pageEditor",arguments: pageNode);
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: ListTile(
                            title: const Text("Media"),
                            leading: const Icon(Icons.photo),
                            onTap: (){
                              
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
            );
          }, 
          icon: const Icon(Icons.add)
        )  
      ],
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
                map.goMyLoc = true;
                map.getLocation();
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

  BottomNavigationBar bottomBarDraw() {
    var keys = bottomNavBarHome.keys.toList();
    return BottomNavigationBar(
      items: keys.map((ele) {
        return BottomNavigationBarItem(
          icon: Icon(bottomNavBarHome[ele]),
          label: ele,
        );
      }).toList(),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      onTap: (index) {
        bottomBarElementFuncs(index);
      },
    );
  }

  void bottomBarElementFuncs(index) {
    // var keys = bottomNavBarHome.keys.toList();
    switch (index) {
      case 0:
        Navigator.pushNamed(context, "/explore");
        break;
      case 1:
        Navigator.pushNamed(context, "/tracer");
        break;
      case 2:
        Navigator.pushNamed(context, "/profile");
        break;
    }
  }
}
