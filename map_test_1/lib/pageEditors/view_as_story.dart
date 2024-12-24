

import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/pageEditors/media_reader.dart';
import 'package:map_test_1/pageEditors/page_reader.dart';

class ViewAsStory extends StatefulWidget{
  const ViewAsStory({super.key});

  @override
  State<ViewAsStory> createState() => _ViewAsStoryState();
}

class _ViewAsStoryState extends State<ViewAsStory>{

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
    return Scaffold(
      // appBar: appBarWidget(context),
      body: Stack(
        children: [
          PageView(
            scrollDirection: Axis.horizontal,
            children: allNodesAsView
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.blueGrey),
              width: MediaQuery.of(context).size.width,
              child: const Center(child: Text("Viewing Story", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),)),
            ) 
          )
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