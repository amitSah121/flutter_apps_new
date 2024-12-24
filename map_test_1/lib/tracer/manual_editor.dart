import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_test_1/constants/constants.dart';
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

class ManualEditor extends StatefulWidget {
  const ManualEditor({super.key});

  @override
  State<ManualEditor> createState() => _ManualEditorState();
}

class _ManualEditorState extends State<ManualEditor> with WidgetsBindingObserver{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var result = 'Search...';
  var map = MapScreen();
  Journey? searchResult;
  bool openRightDrawer = false;
  int selectedNode = 0;
  PathNode? selectedPathNode;
  late Marker currentMarker;
  Object? selectedPageOrMediaNode;
  List<Marker> markers = [];
  late MarkerLayer mLayer;
  int selectedDrawTool = 0;
  double x = 0, y=0;
  PathNode? selectedPathNodeToDetele;
  
  @override
  void dispose() {
    
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

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
      myModel.currentJourney = null;
    });
  }

  @override
  void initState() {
    currentMarker = const Marker(point: LatLng(72, 72), child: Icon(Icons.add_box_rounded));
    markers.add(currentMarker);
    mLayer = MarkerLayer(markers: markers);
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
      map.shouldLessInteract = true;
      map.extralayers = [mLayer];
      map.onTap = (e, pos){
        if(selectedNode == 1){
          if(selectedDrawTool == 0){
            var temp = getClosestPointOnPolyline(Point(pos.latitude,pos.longitude), map.pathNodes!);
            var p1 = temp[0] as Point;
            var a1 = temp[1] as PathNode;
            var b1 = temp[2] as PathNode;
            var aIndex = temp[3] as int;
            var bIndex = temp[4] as int;
            var ratio = findPointRatio(p1, Point(a1.latitude,a1.longitude), Point(b1.latitude,b1.longitude));
            var p = Position(longitude: p1.y, latitude: p1.x, timestamp: DateTime.now(), accuracy: a1.accuracy, altitude: (b1.altitude - a1.altitude)*ratio + a1.altitude, altitudeAccuracy: a1.altitudeAccuracy, heading: a1.heading, headingAccuracy: a1.headingAccuracy, speed: a1.speed, speedAccuracy: a1.speedAccuracy);
            // print({pos.latitude, pos.longitude, temp});
            // currentMarker = Marker(point: LatLng(temp.x, temp.y), child: const Icon(Icons.add_box_rounded));
            // markers.clear();
            // markers.add(currentMarker);
            var time = DateTime.now();
            int id = time.year*pow(10,16)+time.month*pow(10,14)+time.day*pow(10,12)+time.hour*pow(10,10)+time.minute*pow(10,8)+time.second*pow(10,6)+time.microsecond*pow(10,4) as int;
            var newNode = PathNode.fromPosition(p,id);
            if(aIndex < bIndex){
              var pp1 = getAllPageOrMedia(a1, b1);
              for(var t1 in pp1){
                if(t1.runtimeType.toString() == "PageNode"){
                  if((t1 as PageNode).t < ratio){
                    var tt1 = getPageOrMediaPos(t1);
                    var ratio1 = findPointRatio(tt1!, Point(a1.latitude,a1.longitude), Point(newNode.latitude,newNode.longitude));
                    t1.t = ratio1;
                    t1.pathNumber_2 = newNode.pathNumber;
                  }else{
                    var tt1 = getPageOrMediaPos(t1);
                    var ratio1 = findPointRatio(tt1!, Point(newNode.latitude,newNode.longitude), Point(b1.latitude,b1.longitude), );
                    t1.t = ratio1;
                    t1.pathNumber_1 = newNode.pathNumber;
                  }
                }else{
                  if((t1 as MediaNode).t < ratio){
                    var tt1 = getPageOrMediaPos(t1,isPage: false);
                    var ratio1 = findPointRatio(tt1!, Point(a1.latitude,a1.longitude), Point(newNode.latitude,newNode.longitude));
                    t1.t = ratio1;
                    t1.pathNumber_2 = newNode.pathNumber;
                  }else {
                    var tt1 = getPageOrMediaPos(t1,isPage: false);
                    var ratio1 = findPointRatio(tt1!, Point(newNode.latitude,newNode.longitude), Point(b1.latitude,b1.longitude), );
                    t1.t = ratio1;
                    t1.pathNumber_1 = newNode.pathNumber;
                  }
                }
              }
              map.pathNodes!.insert(bIndex,newNode);
            }else{
              var pp1 = getAllPageOrMedia(a1, b1);
              for(var t1 in pp1){
                if(t1.runtimeType.toString() == "PageNode"){
                  if((t1 as PageNode).t < ratio){
                    var tt1 = getPageOrMediaPos(t1);
                    var ratio1 = findPointRatio(tt1!, Point(b1.latitude,b1.longitude), Point(newNode.latitude,newNode.longitude));
                    t1.t = ratio1;
                    t1.pathNumber_2 = newNode.pathNumber;
                  }else{
                    var tt1 = getPageOrMediaPos(t1);
                    var ratio1 = findPointRatio(tt1!, Point(newNode.latitude,newNode.longitude), Point(a1.latitude,a1.longitude), );
                    t1.t = ratio1;
                    t1.pathNumber_1 = newNode.pathNumber;
                  }
                }else{
                  if((t1 as MediaNode).t < ratio){
                    var tt1 = getPageOrMediaPos(t1,isPage: false);
                    var ratio1 = findPointRatio(tt1!, Point(b1.latitude,b1.longitude), Point(newNode.latitude,newNode.longitude));
                    t1.t = ratio1;
                    t1.pathNumber_2 = newNode.pathNumber;
                  }else {
                    var tt1 = getPageOrMediaPos(t1,isPage: false);
                    var ratio1 = findPointRatio(tt1!, Point(newNode.latitude,newNode.longitude), Point(a1.latitude,a1.longitude), );
                    t1.t = ratio1;
                    t1.pathNumber_1 = newNode.pathNumber;
                  }
                }
              }
              map.pathNodes!.insert(aIndex,newNode);
            }
            
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
            // var aIndex = temp[3] as int;
            // var bIndex = temp[4] as int;
            var ratio = findPointRatio(p1, Point(a1.latitude,a1.longitude), Point(b1.latitude,b1.longitude));
            var time = DateTime.now();
            int id = time.year*pow(10,16)+time.month*pow(10,14)+time.day*pow(10,12)+time.hour*pow(10,10)+time.minute*pow(10,8)+time.second*pow(10,6)+time.microsecond*pow(10,4) as int;
            var newNode = PageNode(pathNumber_1: a1.pathNumber, pathNumber_2: b1.pathNumber, t: ratio, rows: RowMap(rows: {}), pageNumber: id,metadata: "fileName=journey;title=untitled;backgroundColor=${Colors.white.value.toString()}");
            map.pageNodes!.add(newNode);
            // print(map.pageNodes!.map((k)=>k.toJson()));
            // print({aIndex,bIndex, ratio, a1.pathNumber, b1.pathNumber});
            setState(() {
              map.childSetState((){
              });
            });

          }else if(selectedDrawTool == 2){
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
            var newNode = MediaNode(pathNumber_1: a1.pathNumber, pathNumber_2: b1.pathNumber, t: ratio,mediaHeight: 300, medialLink: "customUrl/",mediaNumber: id,metadata: "fileName=journey;title=untitled");
            newNode.text = "Write";
            map.mediaNodes!.add(newNode);
            // print(map.pageNodes!.map((k)=>k.toJson()));
            // print({aIndex,bIndex, ratio, a1.pathNumber, b1.pathNumber});
            // print(map.mediaNodes!.length);
            setState(() {
              map.childSetState((){
              });
            });

          }
        }else if(selectedNode == 0){
          var p = map.pathNodes!.map((k)=>Point(k.latitude,k.longitude)).toList();
          var temp = findNearestPoint(Point(pos.latitude,pos.longitude), p);
          // Point tempPoint = temp[0] as Point;
          int index = temp[1] as int;
          // print({ index, p.map((k)=>'${k.x},${k.y}'),pos.latitude,pos.longitude});
          if(index == -1) return;
          selectedPathNode = map.pathNodes![index];
          setState(() {
            
          });
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
          // print(poses.length);

          var p2 = getClosestPointOnPolylinePoints(Point(pos.latitude,pos.longitude), poses);
          if((p2[1] as int) < map.pageNodes!.length){
            selectedPageOrMediaNode = map.pageNodes![p2[1] as int];
          }else{
            selectedPageOrMediaNode = map.mediaNodes![(p2[1] as int)-map.pageNodes!.length];
          }
          // print({p2[1],p2[0],poses});
        }else if(selectedNode == 3){
          List<Point> poses = [];
          for(var m in map.pathNodes!){
            poses.add(Point(m.latitude,m.longitude));
          }
          // print(poses.length);

          var p2 = getClosestPointOnPolylinePoints(Point(pos.latitude,pos.longitude), poses);
          PathNode p3 = map.pathNodes![p2[1] as int];
          selectedPathNodeToDetele = p3;
          showDialog(
            context: context, 
            builder: (context){
              return SimpleDialog(
                backgroundColor: Colors.white12,
                title: const Text("Delete Node"),
                children: [
                    SimpleDialogOption(
                      onPressed: (){
                        Navigator.pop(context);
                        if(map.pathNodes!.length <= 1){
                          map.pathNodes!.remove(selectedPathNodeToDetele);
                          selectedPathNodeToDetele = null;
                          setState(() {
                            map.childSetState((){});
                          });
                          return;
                        }else if(map.pathNodes!.length ==2){
                          var q = getAllPageOrMedia(map.pathNodes![0], map.pathNodes![1]);
                          for(var q1 in q){
                            if(q1.runtimeType.toString() == "PageNode"){
                              map.pageNodes!.remove(q1);
                            }else{
                              map.mediaNodes!.remove(q1);
                            }
                          }
                          selectedPathNodeToDetele = null;
                          setState(() {
                            map.childSetState((){});
                          });
                          return;
                        }
                        int index = map.pathNodes!.indexOf(selectedPathNodeToDetele!);
                        if(index >= map.pathNodes!.length-1){
                          var q = getAllPageOrMedia(map.pathNodes![index], map.pathNodes![index-1]);
                          for(var q1 in q){
                            if(q1.runtimeType.toString() == "PageNode"){
                              map.pageNodes!.remove(q1);
                            }else{
                              map.mediaNodes!.remove(q1);
                            }
                          }
                          map.pathNodes!.remove(selectedPathNodeToDetele);
                          selectedPathNodeToDetele = null;
                        }else if(index <= 0){
                          var q = getAllPageOrMedia(map.pathNodes![index], map.pathNodes![index+1]);
                          for(var q1 in q){
                            if(q1.runtimeType.toString() == "PageNode"){
                              map.pageNodes!.remove(q1);
                            }else{
                              map.mediaNodes!.remove(q1);
                            }
                          }
                          map.pathNodes!.remove(selectedPathNodeToDetele);
                          selectedPathNodeToDetele = null;
                        }else{
                          var q1 = getAllPageOrMedia(map.pathNodes![index], map.pathNodes![index-1]);
                          var q2 = getAllPageOrMedia(map.pathNodes![index], map.pathNodes![index+1]);
                          var a = map.pathNodes![index-1];
                          var b = map.pathNodes![index+1];

                          var q11 = [];
                          var q22 = [];

                          for(var q in q1){
                            if(q.runtimeType.toString() == "PageNode"){
                              q11.add(getPageOrMediaPos(q));
                            }else{
                              q11.add(getPageOrMediaPos(q,isPage: false));
                            }
                          }
                          for(var q in q2){
                            if(q.runtimeType.toString() == "PageNode"){
                              q22.add(getPageOrMediaPos(q));
                            }else{
                              q22.add(getPageOrMediaPos(q,isPage: false));
                            }
                          }
                          map.pathNodes!.remove(selectedPathNodeToDetele);
                          var i = 0;
                          for(var q in q1){
                            if(q.runtimeType.toString() == "PageNode"){
                              (q as PageNode).pathNumber_2 = b.pathNumber;
                              var pos1 = q11[i];
                              var ratio = findPointRatio(pos1!, Point(a.latitude,a.longitude), Point(b.latitude,b.longitude));
                              q.t = ratio;
                            }else{
                              (q as MediaNode).pathNumber_2 = b.pathNumber;
                              var pos1 = q11[i];
                              var ratio = findPointRatio(pos1!, Point(a.latitude,a.longitude), Point(b.latitude,b.longitude));
                              q.t = ratio;
                            }
                            i++;
                          }

                          i=0;
                          for(var q in q2){
                            if(q.runtimeType.toString() == "PageNode"){
                              (q as PageNode).pathNumber_1 = a.pathNumber;
                              var pos1 = q22[i];
                              var ratio = findPointRatio(pos1!, Point(a.latitude,a.longitude), Point(b.latitude,b.longitude));
                              q.t = ratio;
                            }else{
                              (q as MediaNode).pathNumber_1 = a.pathNumber;
                              var pos1 = q22[i];
                              var ratio = findPointRatio(pos1!, Point(a.latitude,a.longitude), Point(b.latitude,b.longitude));
                              q.t = ratio;
                            }
                            i++;
                          }

                          selectedPathNodeToDetele = null;
                        }
                        setState(() {
                          map.childSetState((){});
                        });
                      },
                      child: const Text('Ok'),
                    ),
                    SimpleDialogOption(
                      onPressed: (){
                        Navigator.pop(context);
                        selectedPathNodeToDetele = null;
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
              );
            });
        }
        
      };
      map.onPointerUp = (event, pos){
        if(selectedNode == 0){
          // print({event,pos});
        }
        if(selectedPathNode != null){
          selectedPathNode!.latitude = pos.latitude;
          selectedPathNode!.longitude = pos.longitude;
        }
        selectedPathNode = null;
        // print(pos);
      };

      map.pageNodes = map.pageNodes ?? [];
      Future.microtask(()async{
        await Future.microtask(()async{
          if(map.pathNodes!.length < 2){
            var time = DateTime.now();
            int id = time.year*pow(10,16)+time.month*pow(10,14)+time.day*pow(10,12)+time.hour*pow(10,10)+time.minute*pow(10,8)+time.second*pow(10,6)+time.microsecond*pow(10,4) as int;
            map.pathNodes!.add(PathNode.fromPosition(await determinePosition(), id));
            var temp = PathNode.fromPosition(await determinePosition(), id+1);
            temp.latitude += 0.001;
            map.pathNodes!.add(temp);
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

    Point? selectedPathNodeToDetelePoint;
    if(selectedPathNodeToDetele != null){
      var q1 = Point(selectedPathNodeToDetele!.latitude,selectedPathNodeToDetele!.longitude);
      var p1 = map.getCamera().latLngToScreenPoint(LatLng(q1.x, q1.y));
      selectedPathNodeToDetelePoint = Point(p1.x,p1.y);
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
          myModel.currentJourney = null;
          Navigator.pop(context,"Hello world");
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: appBarWidget(context),
        drawer: appDrawer(context),
        body: Stack(children: [
          if(selectedPathNode==null)
          map,
          if(selectedPathNode!=null)
          GestureDetector(
            child: map,
            onPanDown: (v){
              x = v.globalPosition.dx;
              y = v.globalPosition.dx;
            },
            onVerticalDragUpdate: (v){
              // var p1 = map.getCamera();
              // print(p1.layerPointToLatLng(map.getXYPoint(v.globalPosition.dx, v.globalPosition.dy)));
              // print(map.getXYPoint(v.localPosition.dx, v.localPosition.dy));
              // print(p1.latLngToScreenPoint(LatLng(26, 85)));
              x = v.localPosition.dx;
              y = v.localPosition.dy;

            },
          ),

          if(selectedPathNode!=null)
          // Positioned(
          //   top: y-32,
          //   left: x-32,
          //   child: const Icon(Icons.circle, size: 64)
          // ),
          Positioned(
            top:80,
            left: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Center(child: Container(padding: const EdgeInsets.all(8),decoration: const BoxDecoration(color: Colors.white),child: const Text("Editing Path")))
            ), 
          ),
          if(selectedPageOrMediaPoint != null)
          Positioned(
            left: selectedPageOrMediaPoint.x-16,
            top: selectedPageOrMediaPoint.y-16,
            child: const Icon(Icons.rectangle_outlined,size: 36,)
          ),
          if(selectedPathNodeToDetelePoint != null)
          Positioned(
            left: selectedPathNodeToDetelePoint.x-16,
            top: selectedPathNodeToDetelePoint.y-16,
            child: const Icon(Icons.rectangle_outlined,size: 36,)
          ),
          Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: ListTile(
              leading: result == "Search..."
                  ? const Icon(Icons.search)
                  : const Icon(Icons.edit),
              title: Text(result),
              // onTap: () {
              //   Navigator.pushNamed(context, "/search");
              // },
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
                        // currentMarker = Marker(point: LatLng(temp.x, temp.y), child: const Icon(Icons.rectangle_outlined, size: 36,));
                        
                        // markers.clear();
                        // markers.add(currentMarker);
                        // setState(() {
                        //   map.childSetState((){
                        //     map.dummy = !map.dummy;
                        //   });
                        // });
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
    var keys = bottomNavBarManualEditor.keys.toList();
    final which3 = selectedDrawTool;
    // print(which3);
    int i=-1;
    return BottomNavigationBar(
      items: keys.map((ele) {
        i++;
        return bottomNavBarManualEditor[ele].runtimeType == ([Icons.all_out]).runtimeType ?
        BottomNavigationBarItem(
          icon: ( Icon((bottomNavBarManualEditor[ele]! as List<IconData>)[which3],color: (selectedNode != i) ? Colors.black : Colors.green,)),
          label: ele.split("/")[which3],
        )
        :
        BottomNavigationBarItem(
          icon: Icon(bottomNavBarManualEditor[ele] as IconData,color: (selectedNode != i) ? Colors.black : Colors.green,),
          label: ele,
        );
      }).toList(),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      onTap: (index) {
        bottomBarElementFuncs(index,which3);
      },
    );
  }

  void bottomBarElementFuncs(index, which) {
    switch (index) {
      case 0:
        selectedNode = 0;
        selectedPageOrMediaNode = null;
        break;
      case 1:
        selectedNode = 1;
        selectedPathNode = null;
        selectedPageOrMediaNode = null;
        var keys = bottomNavBarManualEditor.keys.toList()[index].split("/");
        var icons = bottomNavBarManualEditor.values.toList()[index] as List<IconData>;
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
        selectedPathNode = null;
        break;
      case 3:
      selectedNode = 3;
      selectedPageOrMediaNode = null;
      selectedPathNode = null;
        break;
    }
    setState(() {
      
    });
  }
}
