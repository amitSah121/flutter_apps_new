import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/geo_location_worker.dart';
import 'package:map_test_1/helper_classes/helperClasses.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/helper_classes/point.dart';
import 'package:map_test_1/helpers_funcs/drawer_widget.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';
import 'package:map_test_1/helpers_funcs/location_finder.dart';
import 'package:map_test_1/helpers_funcs/misselenious.dart';
import 'package:map_test_1/mapscreen/mapscreen.dart';
import 'package:map_test_1/provider/provider.dart';
import 'package:provider/provider.dart';

class TracerHome extends StatefulWidget {
  const TracerHome({super.key});

  @override
  State<TracerHome> createState() => _TracerHomeState();
}

class _TracerHomeState extends State<TracerHome> with WidgetsBindingObserver{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var result = 'Search...';
  var map = MapScreen();
  Journey? searchResult;
  bool openRightDrawer = false;
  int selectedNode = 3;
  Object? selectedPageOrMediaNode;
  int selectedDrawTool = 0;
  double x = 0, y=0;
  
  @override
  void initState(){
    super.initState();
    map.pathMarkerCustom = const Icon(Icons.circle,size: 4,);
    Geolocator.getPositionStream().listen((Position pos){
      
      if(searchResult!.metadata.split(";")[1].split("=")[1] == "false"){
        var q = searchResult!.pathNodes.last;
        var p = sqrt(pow(pos.altitude-q.altitude,2)+pow(pos.latitude-q.latitude,2)+pow(pos.longitude-q.longitude,2));
        // print(p);
        if(p<distanceToRecord) return;
        var time = DateTime.now();
        int id = time.year*pow(10,16)+time.month*pow(10,14)+time.day*pow(10,12)+time.hour*pow(10,10)+time.minute*pow(10,8)+time.second*pow(10,6)+time.microsecond*pow(10,4) as int;
        searchResult!.pathNodes.add(PathNode.fromPosition(pos,id));
        map.donUseMyGeoLoc = true;
        map.goMyLoc = false;
        map.pathMarkerCustom = const Icon(Icons.circle,size: 4,);
        try{
          if(map.childSetState != null){
            map.childSetState((){});
          }
        }catch (e){}
      }
    
    });
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final myModel = Provider.of<CustomProvider>(context, listen: false);
    if(myModel.currentJourney != null){
      var p = myModel.currentJourney!.metadata.split(";");
      p[1] = "autopathDone=true";
      myModel.currentJourney?.metadata = p.join(";");
      myModel.currentJourney = null;
      setState(() {
        
      });
    }


    Future.microtask(()async{
      final myModel = Provider.of<CustomProvider>(context, listen: false);

      if(myModel.currentJourney!.pathNodes.isNotEmpty){
        await writeJson<PathNode>("$journeyPath/${myModel.currentJourney!.name}/pathNode.json",myModel.currentJourney!.pathNodes);
      }
      if(myModel.currentJourney!.pageNodes.isNotEmpty){
        await writeJson<PageNode>("$journeyPath/${myModel.currentJourney!.name}/pageNode.json",myModel.currentJourney!.pageNodes);
      }
      if(myModel.currentJourney!.mediaNodes.isNotEmpty){
        await writeJson<MediaNode>("$journeyPath/${myModel.currentJourney!.name}/mediaNode.json",myModel.currentJourney!.mediaNodes);
      }
      await writeFile(
          "$journeyPath/${myModel.currentJourney!.name}/metadata", myModel.currentJourney!.metadata);
      // myModel.currentJourney = null;
      if(myModel.currentJourney!.metadata.split(";")[1].split("=")[1] == "true"){
            myModel.currentJourney = null;
      };
    });
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
      // map.shouldLessInteract = true;
      map.onTap = (e, pos){
        if(selectedNode == 1){
          if(selectedDrawTool == 0){
            if(map.pathNodes!.length <= 1) return;
            var temp = getClosestPointOnPolyline(Point(pos.latitude,pos.longitude), map.pathNodes!);
            var p1 = temp[0] as Point;
            var a1 = temp[1] as PathNode;
            var b1 = temp[2] as PathNode;
            // var aIndex = temp[3] as int;
            // var bIndex = temp[4] as int;
            var ratio = findPointRatio(p1, Point(a1.latitude,a1.longitude), Point(b1.latitude,b1.longitude));
            var time = DateTime.now();
            int id = time.year*pow(10,16)+time.month*pow(10,14)+time.day*pow(10,12)+time.hour*pow(10,10)+time.minute*pow(10,8)+time.second*pow(10,6)+time.microsecond*pow(10,4) as int;
            var newNode = PageNode(pathNumber_1: a1.pathNumber, pathNumber_2: b1.pathNumber, t: ratio, rows: RowMap(rows: {}), pageNumber: id,metadata: "fileName=journey;title=untitled;backgroundColor=${Colors.white.value.toString()}");
            map.pageNodes!.add(newNode);
            setState(() {
              map.childSetState((){
              });
            });

          }else if(selectedDrawTool == 1){
            if(map.pathNodes!.length <= 1) return;
            var temp = getClosestPointOnPolyline(Point(pos.latitude,pos.longitude), map.pathNodes!);
            var p1 = temp[0] as Point;
            var a1 = temp[1] as PathNode;
            var b1 = temp[2] as PathNode;
            var ratio = findPointRatio(p1, Point(a1.latitude,a1.longitude), Point(b1.latitude,b1.longitude));
            var time = DateTime.now();
            int id = time.year*pow(10,16)+time.month*pow(10,14)+time.day*pow(10,12)+time.hour*pow(10,10)+time.minute*pow(10,8)+time.second*pow(10,6)+time.microsecond*pow(10,4) as int;
            var newNode = MediaNode(pathNumber_1: a1.pathNumber, pathNumber_2: b1.pathNumber, t: ratio,mediaHeight: 300, medialLink: "customUrl/",mediaNumber: id,metadata: "fileName=journey;title=untitled");
            newNode.text = "Write";
            map.mediaNodes!.add(newNode);
            setState(() {
              map.childSetState((){
              });
            });

          }
        }else if(selectedNode == 2){
          List<Point> poses = [];
          for(var m in map.pageNodes!){
            var p1 = getPageOrMediaPos(m);
            poses.add(p1!);
          }
          for(var m in map.mediaNodes!){
            var p1 = getPageOrMediaPos(m,isPage: false);
            poses.add(p1!);
          }

          var p2 = getClosestPointOnPolylinePoints(Point(pos.latitude,pos.longitude), poses);
          if((p2[1] as int) < map.pageNodes!.length){
            selectedPageOrMediaNode = map.pageNodes![p2[1] as int];
          }else{
            selectedPageOrMediaNode = map.mediaNodes![(p2[1] as int)-map.pageNodes!.length];
          }
        }
        
      };

      map.pageNodes = map.pageNodes ?? [];
      Future.microtask(()async{
        await Future.microtask(()async{
          if(map.pathNodes!.isEmpty){
            var time = DateTime.now();
            int id = time.year*pow(10,16)+time.month*pow(10,14)+time.day*pow(10,12)+time.hour*pow(10,10)+time.minute*pow(10,8)+time.second*pow(10,6)+time.microsecond*pow(10,4) as int;
            map.pathNodes!.add(PathNode.fromPosition(await determinePosition(), id));
          }
          setState(() {
            
          });
        });

        map.donUseMyGeoLoc = true;
      });
      
    }
    
    Point? selectedPageOrMediaPoint;
    if(selectedPageOrMediaNode != null){
      if(selectedPageOrMediaNode!.runtimeType.toString() == "PageNode"){
        var q1 = getPageOrMediaPos(selectedPageOrMediaNode);
        var p1 = map.getCamera().latLngToScreenPoint(LatLng(q1!.x, q1!.y));
        selectedPageOrMediaPoint = Point(p1.x,p1.y);
      }else {
        var q1 = getPageOrMediaPos(selectedPageOrMediaNode, isPage: false);
        var p1 = map.getCamera().latLngToScreenPoint(LatLng(q1!.x, q1!.y));
        selectedPageOrMediaPoint = Point(p1.x,p1.y);
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        if (context.mounted) {
          if(myModel.currentJourney!.pathNodes.isNotEmpty){
            await writeJson<PathNode>("$journeyPath/${myModel.currentJourney!.name}/pathNode.json",myModel.currentJourney!.pathNodes);
          }
          if(myModel.currentJourney!.pageNodes.isNotEmpty){
            await writeJson<PageNode>("$journeyPath/${myModel.currentJourney!.name}/pageNode.json",myModel.currentJourney!.pageNodes);
          }
          if(myModel.currentJourney!.mediaNodes.isNotEmpty){
            await writeJson<MediaNode>("$journeyPath/${myModel.currentJourney!.name}/mediaNode.json",myModel.currentJourney!.mediaNodes);
          }
          await writeFile(
              "$journeyPath/${myModel.currentJourney!.name}/metadata", myModel.currentJourney!.metadata);
          
          bool isTracedDone = searchResult!.metadata.split(";")[1].split("=")[1] == "true";
          if(isTracedDone){
            myModel.currentJourney = null;
          }
          Navigator.pop(context,"Hello world");
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: appBarWidget(context),
        drawer: appDrawer(context),
        body: Stack(children: [
          map,
          if(selectedPageOrMediaPoint != null)
          Positioned(
            left: selectedPageOrMediaPoint.x-16,
            top: selectedPageOrMediaPoint.y-16,
            child: const Icon(Icons.rectangle_outlined,size: 36,)
          ),
          Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: ListTile(
              leading: result == "Search..."
                  ? const Icon(Icons.search)
                  : const Icon(Icons.edit),
              title: Text(result),
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
                  Container(
                    decoration: BoxDecoration(color:(selectedPageOrMediaNode == map.pageNodes![index]) ? Colors.blue.withAlpha(50) : Colors.transparent),
                    child: ListTile(
                      title: Text(map.pageNodes![index].metadata.split(";")[1].split("=")[1]),
                      leading: const Icon(Icons.book),
                      onTap: (){
                        selectedPageOrMediaNode = map.pageNodes![index];
                        var temp = getPageOrMediaPos(selectedPageOrMediaNode);
                        // print(temp?.x);
                        if(temp == null) return;
                      },
                      onLongPress: (){
                        showDialog(
                          context: context, 
                          builder: (context){
                            return AlertDialog(
                              title: const Text("PageNode"),
                              content: SizedBox(
                                width: 120,
                                height: 64*3,
                                child: ListView(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.edit),
                                      title: const Text("Edit"),
                                      onTap: (){
                                        Navigator.pop(context);
                                        Navigator.pushNamed(context,"/pageEditor",arguments: {"node":map.pageNodes![index],"path":""});
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.edit_calendar),
                                      title: const Text("Rename"),
                                      onTap: (){
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context, 
                                          builder: (context){
                                            var controller = TextEditingController();
                                            controller.text = map.pageNodes![index].metadata.split(";")[1].split("=")[1];
                                            return AlertDialog(
                                              alignment: Alignment.center,
                                              title: const Text("Rename"),
                                              content: TextField(
                                                controller: controller,
                                                onChanged: (value) {
                                                  var p1 = map.pageNodes![index].metadata.split(";");
                                                  p1[1] = "title=$value";
                                                  map.pageNodes![index].metadata = p1.join(";");
                                                },
                                                onSubmitted: (v){
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            );
                                          }
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: const Text("Delete"),
                                      onTap: (){
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return SimpleDialog(
                                              title: const Text('Delete node?'),
                                              children: [
                                                SimpleDialogOption(
                                                  onPressed: (){
                                                    setState(() {
                                                      Navigator.pop(context);
                                                      map.pageNodes!.removeAt(index);
                                                      map.childSetState((){});
                                                    });
                                                  },
                                                  child: const Text('Ok'),
                                                ),
                                                SimpleDialogOption(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ),
                            );
                        });
                      },
                    ),
                  )
                  :
                  Container(
                    decoration: BoxDecoration(color:(selectedPageOrMediaNode == map.mediaNodes![index-map.pageNodes!.length]) ? Colors.blue.withAlpha(50) : Colors.transparent),
                    child: ListTile(
                      title: Text(map.mediaNodes![index-map.pageNodes!.length].metadata.split(";")[1].split("=")[1]),
                      leading: const Icon(Icons.photo),
                      onTap: (){
                        selectedPageOrMediaNode = map.mediaNodes![index-map.pageNodes!.length];
                      },
                      onLongPress: (){
                        showDialog(
                          context: context, 
                          builder: (context){
                            return AlertDialog(
                              title: const Text("MediaNode"),
                              content: SizedBox(
                                width: 120,
                                height: 64*3,
                                child: ListView(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.edit),
                                      title: const Text("Edit"),
                                      onTap: (){
                                        Navigator.pop(context);
                                        Navigator.pushNamed(context,"/mediaEditor",arguments: {"node":map.mediaNodes![index - map.pageNodes!.length],"path":""});
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.edit_calendar),
                                      title: const Text("Rename"),
                                      onTap: (){
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context, 
                                          builder: (context){
                                            var controller = TextEditingController();
                                            controller.text = map.mediaNodes![index-map.pageNodes!.length].metadata.split(";")[1].split("=")[1];
                                            return AlertDialog(
                                              alignment: Alignment.center,
                                              title: const Text("Rename"),
                                              content: TextField(
                                                controller: controller,
                                                onChanged: (value) {
                                                  var p1 = map.pageNodes![index-map.pageNodes!.length].metadata.split(";");
                                                  p1[1] = "title=$value";
                                                  map.mediaNodes![index-map.pageNodes!.length].metadata = p1.join(";");
                                                },
                                                onSubmitted: (v){
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            );
                                          }
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: const Text("Delete"),
                                      onTap: (){
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (context){
                                            return SimpleDialog(
                                              title: const Text('Delete node?'),
                                              children: [
                                                SimpleDialogOption(
                                                  onPressed: (){
                                                    setState(() {
                                                      Navigator.pop(context);
                                                      map.mediaNodes!.removeAt(index-map.pageNodes!.length);
                                                      map.childSetState((){});
                                                    });
                                                  },
                                                  child: const Text('Ok'),
                                                ),
                                                SimpleDialogOption(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                              ],
                                            );
                                          }
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ),
                            );
                        });
                      },
                    ),
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
                            if(map.pathNodes!.length >= 2)
                            drawAltitude(MediaQuery.of(context).size.width*0.9, 64)// made for having different icons in column
                          ]))
                    ],
                  )),
            ),
        ]),
        floatingActionButton: floatingActionWidget(),
        bottomNavigationBar: bottomBarDraw(),
      ),
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
            createPageMediaNode(context,setState);
          }, 
          icon: const Icon(Icons.add)
        )  
      ],
    );
  }

  Point? getPageOrMediaPos(node,{isPage=true}){
    if(node == null) return null;
    PathNode? temp;
    Point? p1;
    for(var p in map.pathNodes!){
      if(temp == null){
        temp = p;
      }else{
        var q;
        if(isPage){
          q = node! as PageNode;
        }else{
          q = node! as MediaNode;
        }
        if((q.pathNumber_1 == p.pathNumber && q.pathNumber_2 == temp.pathNumber)){
          var longitude = (temp.longitude - p.longitude)*q.t + p.longitude;
          var latitude = (temp.latitude - p.latitude)*q.t + p.latitude;
          p1 = Point(latitude,longitude );
          break;
        }else if((q.pathNumber_1 == temp.pathNumber && q.pathNumber_2 == p.pathNumber)){
          var longitude = (p.longitude - temp.longitude)*q.t + temp.longitude;
          var latitude = (p.latitude - temp.latitude)*q.t + temp.latitude;
          p1 = Point(latitude,longitude );
          break;
        }
      }
      temp = p;
    }
    return p1;
  }


  List<Object> getAllPageOrMedia(node1,node2){
    if(node1 == null || node2 == null) return [];
    List<Object> p1 = [];
    for(var p in map.pageNodes!){
      if((p.pathNumber_1 == node1.pathNumber && p.pathNumber_2 == node2.pathNumber) || (p.pathNumber_1 == node2.pathNumber && p.pathNumber_2 == node1.pathNumber)){
        p1.add(p);
      }
    }

    for(var p in map.mediaNodes!){
      if((p.pathNumber_1 == node1.pathNumber && p.pathNumber_2 == node2.pathNumber) || (p.pathNumber_1 == node2.pathNumber && p.pathNumber_2 == node1.pathNumber)){
        p1.add(p);
      }
    }
    return p1;
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

  BottomNavigationBar bottomBarDraw() {
    var keys = bottomNavBarTracerHome.keys.toList();

    bool isTracedDone = searchResult!.metadata.split(";")[1].split("=")[1] == "true";
    final which21 = !isTracedDone ? 0 : 1;
    final which2 = selectedDrawTool;
    // print(which3);
    int i=-1;
    return BottomNavigationBar(
      items: keys.map((ele) {
        i++;
        var which = 0;
        if(ele.contains("tracing")){
          which = which21;
        }else{
          which = which2;
        }
        return bottomNavBarTracerHome[ele].runtimeType == ([Icons.all_out]).runtimeType ?
        BottomNavigationBarItem(
          icon: ( Icon((bottomNavBarTracerHome[ele]! as List<IconData>)[which],color: (selectedNode != i) ? Colors.black : Colors.green,)),
          label: ele.split("/")[which],
        )
        :
        BottomNavigationBarItem(
          icon: Icon(bottomNavBarTracerHome[ele] as IconData,color: (selectedNode != i) ? Colors.black : Colors.green,),
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

  void bottomBarElementFuncs(index, which) {
    map.shouldLessInteract = true;
    map.childSetState((){});
    setState(() {
      
    });
    switch (index) {
      case 0:
        if(which == 0){
          final myModel = Provider.of<CustomProvider>(context, listen: false);
          if(myModel.currentJourney != null){
            var p = myModel.currentJourney!.metadata.split(";");
            p[1] = "autopathDone=true";
            myModel.currentJourney?.metadata = p.join(";");
            setState(() {
              
            });
          }
        }
        break;
      case 1:
        selectedNode = 1;
        selectedPageOrMediaNode = null;
        var keys = bottomNavBarTracerHome.keys.toList()[index].split("/");
        var icons = bottomNavBarTracerHome.values.toList()[index] as List<IconData>;
        var i=-1;
        List<Widget> modelList = keys.map((ele) {
          var currentI = i;
          i++;
          return SizedBox(
            width: 120,
            height: 64,
            child: ListTile(
              leading: Icon(icons[i]),
              title: Text(keys[i]),
              onTap: (){
                selectedDrawTool = currentI+1;
                Navigator.pop(context);
                setState(() {
                  
                });
              },
            ),
          );
        }).toList();
        showDialog(
          context: context, 
          builder: (context){
            return AlertDialog(
              content: SizedBox(
                width: 120,
                height: 64*3,
                child: ListView(
                  children: modelList
                ),
              )
            );
          });
        break;
      case 2:
        selectedNode = 2;
        break;
      case 3:
        selectedNode = 4;
        selectedPageOrMediaNode = null;
        map.shouldLessInteract = false;
        map.childSetState((){});
        setState(() {
          
        });
        break;
    }
    setState(() {
      
    });
  }
}
