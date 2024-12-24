import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helper_classes/helperClasses.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/helpers_funcs/drawer_widget.dart';
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

class _HomeState extends State<Home> with WidgetsBindingObserver{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var result = 'Search...';
  var map = MapScreen();
  Journey? searchResult;
  bool openRightDrawer = false;

  @override
  void initState() {
    super.initState();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   print(state);
  //   if(state == AppLifecycleState.paused){
  //     print("paused");
  //   }else if(state == AppLifecycleState.resumed){
  //     print("resumed");
  //   }else if(state == AppLifecycleState.detached){
  //     print("detached");
  //   }else if(state == AppLifecycleState.hidden){
  //     print("paused");
  //   }else if(state == AppLifecycleState.inactive){
  //     print("inactive");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      searchResult = args as Journey;
      result = searchResult!.metadata.split(";")[0].split("=")[1];
      map.pathNodes = searchResult!.pathNodes;
      map.pageNodes = searchResult!.pageNodes;
      map.mediaNodes = searchResult!.mediaNodes;
      map.goMyLoc = false;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: appBarWidget(context),
      drawer: appDrawer(context),
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
        if (searchResult != null &&
            openRightDrawer) // this is to implement altitude
          Positioned(
            right: 0,
            top: 100,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              width: noteDisplaySize[0],
              height: MediaQuery.of(context).size.height * 0.5,
              child: ListView.builder(
                  itemCount: map.pageNodes!.length + map.mediaNodes!.length,
                  itemBuilder: (context, index) {
                    return (index < map.pageNodes!.length)
                        ? ListTile(
                            title: const Text("Pages"),
                            leading: const Icon(Icons.book),
                            onTap: () {
                              Navigator.pushNamed(context, "/pageReader",
                                  arguments: map.pageNodes![index]);
                            },
                          )
                        : ListTile(
                            title: const Text("Media"),
                            leading: const Icon(Icons.photo),
                            onTap: () {
                              Navigator.pushNamed(context, "/mediaReader",
                                  arguments: map.mediaNodes![
                                      index - map.pageNodes!.length]);
                            },
                          );
                  }),
            ),
          ),
        if (!openRightDrawer && searchResult != null)
          Positioned(
              right: 0,
              top: 100,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    border: Border(
                      left: BorderSide(color: Colors.black, width: 3),
                    )),
                width: noteDisplaySize[1],
                height: MediaQuery.of(context).size.height * 0.5,
              )),
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
                          drawAltitude(MediaQuery.of(context).size.width * 0.9,
                              64) // made for having different icons in column
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
    List<double> xes =
        generateEvenlySpaced(0, width, searchResult!.pathNodes.length);
    int i = -1;
    List<Offset> offsets = searchResult!.pathNodes.map((p) {
      i++;
      return Offset(xes[i], p.altitude);
    }).toList();
    return CustomPaint(
      size: Size(width, height), // Define the size of the canvas
      painter: LinePainter(offsets),
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
                  // print(await readFile(fileName))
                  // final myModel =
                  //     Provider.of<CustomProvider>(context, listen: false);
                  // print(myModel.currentJourney!.metadata);
                  // print(await readFile("journey/2024-12-20 17-03-43.276614/metadata"));
                  // print(await readFile("journey/2024-12-20 17-03-43.276614/pathNode.json"));
                  // print(await readFile("journey/2024-12-20 17-03-43.276614/pageNode.json"));
                  // print(await readFile("journey/2024-12-20 17-03-43.276614/mediaNode.json"));
                  await listFilesDirs(dir: journeyPath, pattern: "*");
                } catch (e) {
                  print(e);
                }
              });

              // Navigator.pushNamed(context, "/notifications");
            },
            icon: const Icon(Icons.notifications)),
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
            if (searchResult != null)
              IconButton(
                onPressed: () {
                  openRightDrawer = !openRightDrawer;
                  setState(() {});
                },
                icon: Icon(!openRightDrawer ? Icons.menu_open : Icons.close),
                iconSize: 36,
              ),
            IconButton(
              onPressed: () async {
                var time = DateTime.now().toString().replaceAll(":", "-");
                MediaNode mediaNode = MediaNode(
                  pathNumber_1: -1, // means not connected to journey
                  pathNumber_2: -1, // means not connected to journey
                  t: 0,
                  text: "write",
                  medialLink: "customUrl/",
                  mediaHeight: 300,
                  mediaNumber: -1, // means not connected to journey
                  metadata: "fileName=$time;title=untitled",
                );
                await Future.microtask(() async {
                  await getFile("mediaNode/$time");
                  await writeFile(
                      "mediaNode/$time", jsonEncode(mediaNode.toJson()));
                  final myModel =
                      Provider.of<CustomProvider>(context, listen: false);
                  myModel.mediaNodes.add(mediaNode);
                  await Navigator.pushNamed(context, "/mediaEditor",
                      arguments: {
                        "node": mediaNode,
                        "path": "mediaNode/$time"
                      });
                  setState(() {});
                });
              },
              icon: const Icon(Icons.camera),
              iconSize: 36,
            )
          ],
        ),
      ),
    );
  }

  BottomNavigationBar bottomBarDraw() {
    var keys = bottomNavBarHome.keys.toList();
    final myModel = Provider.of<CustomProvider>(context, listen: false);
    final which2 = myModel.currentJourney == null ? 0 : 1;
    return BottomNavigationBar(
      items: keys.map((ele) {
        return bottomNavBarHome[ele].runtimeType ==
                ([Icons.all_out]).runtimeType
            ? BottomNavigationBarItem(
                icon: Icon((bottomNavBarHome[ele]! as List<IconData>)[which2]),
                label: ele.split("/")[which2],
              )
            : BottomNavigationBarItem(
                icon: Icon(bottomNavBarHome[ele] as IconData),
                label: ele,
              );
      }).toList(),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      onTap: (index) {
        bottomBarElementFuncs(index, which2);
      },
    );
  }

  void bottomBarElementFuncs(index, which2) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, "/explore");
        break;
      case 1:
        if (which2 == 1) {
          Navigator.pushNamed(context, "/tracer");
        } else {
          addJourney();
        }
        break;
      case 3:
        Navigator.pushNamed(context, "/profile");
        break;
    }
  }

  Future<dynamic> addJourney() {
    return showDialog(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
              alignment: Alignment.center,
              title: const Text("Title"),
              content: TextField(
                  controller: controller,
                  onSubmitted: (val) {
                    Navigator.pop(context);
                    var title = "untitled";
                    if (val.isNotEmpty) {
                      title = val;
                    }

                    final myModel =
                        Provider.of<CustomProvider>(context, listen: false);
                    var time = DateTime.now().toString().replaceAll(":", "-");
                    Journey temp = Journey(time);
                    myModel.currentJourney = temp;
                    myModel.journeys.add(temp);
                    temp.metadata = "title=$title;autopathDone=false";
                    Future.microtask(() async {
                      await getDir("$journeyPath/$time");
                      await getFile("$journeyPath/$time/pathNode.json");
                      await getFile("$journeyPath/$time/pageNode.json");
                      await getFile("$journeyPath/$time/mediaNode.json");
                      await writeFile(
                          "$journeyPath/$time/metadata", temp.metadata);
                      // await Navigator.pushNamed(context, "/tracer");
                    });
                  }));
        });
  }
}
