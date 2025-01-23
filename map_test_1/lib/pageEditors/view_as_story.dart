

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/helper_classes/point.dart';
import 'package:map_test_1/mapscreen/mapscreen.dart';
import 'package:map_test_1/pageEditors/media_reader.dart';
import 'package:map_test_1/pageEditors/page_reader.dart';

class ViewAsStory extends StatefulWidget{
  const ViewAsStory({super.key});

  @override
  State<ViewAsStory> createState() => _ViewAsStoryState();
}

class _ViewAsStoryState extends State<ViewAsStory>{
  MapScreen map = MapScreen();
  var pos;

  @override
  Widget build(BuildContext context){
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final journey = arguments["node"]; // actually only journey are allowed
    var temp;
    var allNodesArranged = [];
    for(var p in journey.pathNodes){
      if(temp != null){
        var p1 = getAllPageOrMedia(temp, p, journey.pageNodes, journey.mediaNodes);
        p1.sort((a,b){
          var a1,b1;
          if(a.runtimeType.toString() == "PageNode"){
            a1 = a as PageNode;
          }else{
            a1 = a as MediaNode;
          }

          if(b.runtimeType.toString() == "PageNode"){
            b1 = b as PageNode;
          }else{
            b1 = b as MediaNode;
          }
          return ((a1.t - b1.t)*10000000000 as double).toInt();
        });
        allNodesArranged.addAll(p1);
      }
      temp = p;
    }
    List<Widget> allNodesAsView = allNodesArranged.map((k){
      if(k.runtimeType.toString() == "PageNode"){
        var t1 = PageReader();
        t1.pageNode = k as PageNode;
        return t1;
      }else{
        var t1 = MediaReader();
        t1.mediaNode = k as MediaNode;
        return t1;
      }
    }).toList();

    map.pathNodes = journey.pathNodes;
    map.pageNodes = journey.pageNodes;
    map.mediaNodes = journey.mediaNodes;
    var pageViewController = PageController();
    if(map.extralayers.isEmpty){
      var p1 = allNodesArranged[0];
      var t1;
      var ratio = p1.t;
      for(var temp in journey.pathNodes){
        if(t1 != null){
          if(p1.pathNumber_1 == t1.pathNumber && p1.pathNumber_2 == temp.pathNumber){
            pos = Point((temp.latitude - t1.latitude)*ratio+t1.latitude,(temp.longitude - t1.longitude)*ratio+t1.longitude);
            break;
          }else if(p1.pathNumber_2 == t1.pathNumber && p1.pathNumber_1 == temp.pathNumber){
            pos = Point((t1.latitude - temp.latitude)*ratio+temp.latitude,(t1.longitude - temp.longitude)*ratio+temp.longitude);
            break;
          }
        }
        t1 = temp;
      }
      map.extralayers.clear();
      map.extralayers.add(MarkerLayer(markers: [Marker(point:LatLng(pos.x,pos.y), child: const Icon(Icons.circle,size: 32,color: Colors.blue,)),]));
    }
    
    pageViewController.addListener((){
      if(pageViewController.page!.toInt() == pageViewController.page){
        var p1 = allNodesArranged[pageViewController.page!.toInt()];
        var t1;
        var ratio = p1.t;
        for(var temp in journey.pathNodes){
          if(t1 != null){
            if(p1.pathNumber_1 == t1.pathNumber && p1.pathNumber_2 == temp.pathNumber){
              pos = Point((temp.latitude - t1.latitude)*ratio+t1.latitude,(temp.longitude - t1.longitude)*ratio+t1.longitude);
              break;
            }else if(p1.pathNumber_2 == t1.pathNumber && p1.pathNumber_1 == temp.pathNumber){
              pos = Point((t1.latitude - temp.latitude)*ratio+temp.latitude,(t1.longitude - temp.longitude)*ratio+temp.longitude);
              break;
            }
          }
          t1 = temp;
        }
        map.extralayers.clear();
        map.extralayers.add(MarkerLayer(markers: [Marker(point:LatLng(pos.x,pos.y), child: const Icon(Icons.circle,size: 32,color: Colors.blue,)),]));
        map.childSetState((){});
        // pos = map.getCamera().latLngToScreenPoint(LatLng(pos.x, pos.y));
        setState(() {
        });
      }
    });
          // print(pos);

    return Scaffold(
      // appBar: appBarWidget(context),
      body: Stack(
        children: [
          PageView(
            controller: pageViewController,
            scrollDirection: Axis.horizontal,
            children: allNodesAsView
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.1, // Initial size (collapsed height)
            minChildSize: 0.1, // Minimum height (when fully collapsed)
            maxChildSize: 0.7, // Maximum height (when fully expanded)
            builder: (context, scrollController) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: 500,
                decoration: BoxDecoration(color: Colors.blue[50]),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Scroll Up"),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 500,
                        child: Stack(
                          children: [
                            map,
                            // if(pos != null)
                            // Positioned(
                            //   top: pos.y,
                            //   left: pos.y,
                            //   child: const Icon(Icons.circle,size: 100,))
                          ]),
                      ),
                  
                    ],
                  ),
                )
              );
            }),

          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.blueGrey),
              width: MediaQuery.of(context).size.width,
              child: const Center(child: Text("Viewing Story", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),)),
            ) 
          ),
        ],
      ),
    );
  }

  List<Object> getAllPageOrMedia(node1,node2,pageNodes,mediaNodes){
    if(node1 == null || node2 == null) return [];
    List<Object> p1 = [];
    for(var p in pageNodes!){
      if((p.pathNumber_1 == node1.pathNumber && p.pathNumber_2 == node2.pathNumber) || (p.pathNumber_1 == node2.pathNumber && p.pathNumber_2 == node1.pathNumber)){
        p1.add(p);
      }
    }

    for(var p in mediaNodes!){
      if((p.pathNumber_1 == node1.pathNumber && p.pathNumber_2 == node2.pathNumber) || (p.pathNumber_1 == node2.pathNumber && p.pathNumber_2 == node1.pathNumber)){
        p1.add(p);
      }
    }
    return p1;
  }



  // AppBar appBarWidget(BuildContext context) {
  //   return AppBar(
  //     title: const Text(appname),
  //   );
  // }
}