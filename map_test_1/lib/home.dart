import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/geo_location_worker.dart';
import 'package:map_test_1/helper_classes/helperClasses.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/helper_classes/point.dart';
import 'package:map_test_1/helpers_funcs/apis.dart';
import 'package:map_test_1/helpers_funcs/drawer_widget.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';
import 'package:map_test_1/helpers_funcs/location_finder.dart';
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
  late GeoLocationWorker gW;
  late var center;
  late var p1;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5),(){
      map.goMyLoc = false;
      map.donUseMyGeoLoc = true;
      Geolocator.getPositionStream().listen((pos){
        map.current = pos;
        try{
          if(map.childSetState != null){
            map.childSetState((){});
          }
        }catch (e){}
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
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
                  // FlutterForegroundTask.sendDataToTask({"Hello"});
                  // await listFilesDirs(dir: journeyPath, pattern: "*");
                  // print(await listFilesOnly(dir:"journey"));

                  // await getAnyOtherFile("amit", "amitsah", "allFilesClient");
                  // print("helli");
                  // print(await readFile("allFilesClient"));
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
                showDialog(
                  context: context, 
                  builder: (context){
                    return SimpleDialog(
                      title: const Text("Do you want to add media to your journey? Otherwise will be added to your extra media folder."),
                      children: [
                        SimpleDialogOption(
                          onPressed: ()async {
                            Navigator.pop(context);
                            final myModel = Provider.of<CustomProvider>(context, listen: false);
                            if(myModel.currentJourney == null || (myModel.currentJourney != null && myModel.currentJourney!.metadata.split(";")[1].split("=")[1] == "true") ) return;
                            if(myModel.currentJourney!.pathNodes.length <= 1) return;
                            var pos = await determinePositionWithoutCallingPermission();
                            var time = DateTime.now();
                            int id = time.year*pow(10,16)+time.month*pow(10,14)+time.day*pow(10,12)+time.hour*pow(10,10)+time.minute*pow(10,8)+time.second*pow(10,6)+time.microsecond*pow(10,4) as int;
                            myModel.currentJourney!.pathNodes.add(PathNode.fromPosition(pos, id));
                            var temp = getClosestPointOnPolyline(Point(pos.latitude,pos.longitude), myModel.currentJourney!.pathNodes);
                            var p1 = temp[0] as Point;
                            var a1 = temp[1] as PathNode;
                            var b1 = temp[2] as PathNode;
                            var ratio = findPointRatio(p1, Point(a1.latitude,a1.longitude), Point(b1.latitude,b1.longitude));
                            // var time = DateTime.now();
                            id = (time.year*pow(10,16)+time.month*pow(10,14)+time.day*pow(10,12)+time.hour*pow(10,10)+time.minute*pow(10,8)+time.second*pow(10,6)+time.microsecond*pow(10,4) +1 )as int;
                            var newNode = MediaNode(pathNumber_1: a1.pathNumber, pathNumber_2: b1.pathNumber, t: ratio,mediaHeight: 300, medialLink: "customUrl/",mediaNumber: id,metadata: "fileName=journey;title=untitled");
                            newNode.text = "Write";
                            myModel.currentJourney!.mediaNodes.add(newNode);
                            
                            Navigator.pushNamed(context,"/mediaEditor",arguments: {"node":newNode,"path":""});
                          },
                          child: const Text("Okay"),
                        ),
                        SimpleDialogOption(
                          onPressed: () async {
                            Navigator.pop(context);
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
                          },
                          child: const Text("No"),
                        ),
                      ],
                    );
                });
                
              },
              icon: const Icon(Icons.camera),
              iconSize: 36,
            ),
            IconButton(
              onPressed: () async {
                showDialog(
                  context: context, 
                  builder: (context){
                    return SimpleDialog(
                      title: const Text("Do you want to add page to your journey? Otherwise will be added to your extra media folder."),
                      children: [
                        SimpleDialogOption(
                          onPressed: ()async {
                            Navigator.pop(context);
                            final myModel = Provider.of<CustomProvider>(context, listen: false);
                            if(myModel.currentJourney == null || (myModel.currentJourney != null && myModel.currentJourney!.metadata.split(";")[1].split("=")[1] == "true") ) return;
                            if(myModel.currentJourney!.pathNodes.length <= 1) return;
                            var pos = await determinePositionWithoutCallingPermission();
                            var time = DateTime.now();
                            int id = time.year*pow(10,16)+time.month*pow(10,14)+time.day*pow(10,12)+time.hour*pow(10,10)+time.minute*pow(10,8)+time.second*pow(10,6)+time.microsecond*pow(10,4) as int;
                            myModel.currentJourney!.pathNodes.add(PathNode.fromPosition(pos, id));
                            var temp = getClosestPointOnPolyline(Point(pos.latitude,pos.longitude), myModel.currentJourney!.pathNodes);
                            var p1 = temp[0] as Point;
                            var a1 = temp[1] as PathNode;
                            var b1 = temp[2] as PathNode;
                            var ratio = findPointRatio(p1, Point(a1.latitude,a1.longitude), Point(b1.latitude,b1.longitude));
                            // var time = DateTime.now();
                            id = (time.year*pow(10,16)+time.month*pow(10,14)+time.day*pow(10,12)+time.hour*pow(10,10)+time.minute*pow(10,8)+time.second*pow(10,6)+time.microsecond*pow(10,4) +1 )as int;
                            var newNode = PageNode(pathNumber_1: a1.pathNumber, pathNumber_2: b1.pathNumber, t: ratio, rows: RowMap(rows: {}), pageNumber: id,metadata: "fileName=journey;title=untitled;backgroundColor=${Colors.white.value.toString()}");
                            map.pageNodes!.add(newNode);
                            myModel.currentJourney!.pageNodes.add(newNode);
                            
                            Navigator.pushNamed(context,"/pageEditor",arguments: {"node":newNode,"path":""});
                          },
                          child: const Text("Okay"),
                        ),
                        SimpleDialogOption(
                          onPressed: () async {
                            Navigator.pop(context);
                            var time = DateTime.now().toString().replaceAll(":", "-");
                            PageNode pageNode = PageNode(
                              rows: RowMap(
                                rows: {},
                              ),
                              pathNumber_1: -1, // means not connected to journey
                              pathNumber_2: -1, // means not connected to journey
                              t: 0,
                              pageNumber: -1, // means not connected to journey
                              metadata:
                                  "fileName=$time;title=untitled;backgroundColor=${Colors.white.value.toString()}",
                            );
                          
                            await getFile("pageNode/$time");
                            await writeFile(
                                "pageNode/$time", jsonEncode(pageNode.toJson()));
                            final myModel =
                                Provider.of<CustomProvider>(context, listen: false);
                            myModel.pageNodes.add(pageNode);
                            await Navigator.pushNamed(context, "/pageEditor",
                                arguments: {
                                  "node": pageNode,
                                  "path": "pageNode/$time"
                                });
                            setState(() {});
                          },
                          child: const Text("No"),
                        ),
                      ],
                    );
                });
                
              },
              icon: const Icon(Icons.book),
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
    final which2 = (myModel.currentJourney != null && myModel.currentJourney!.metadata.split(";")[1].split("=")[1] == "true" )   || myModel.currentJourney == null ? 0 : 1;
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
                      await Navigator.pushNamed(context, "/tracer");
                    });
                  }));
        });
  }
}
