import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';
import 'package:map_test_1/provider/provider.dart';
import 'package:provider/provider.dart';

List<double> generateEvenlySpaced(double min, double max, int n) {
  if (n <= 1) {
    // throw ArgumentError("n must be greater than 1 to create evenly spaced values.");
    return [];
  }
  double step = (max - min) / (n - 1);
  return List<double>.generate(n, (i) => min + i * step);
}

List<LatLng> createPolygonFromPathNodes(List<PathNode> pathNodes) {
  return pathNodes.map((p) => LatLng(p.latitude, p.longitude)).toList();
}


Future<dynamic> createPageMediaNode(BuildContext context) {
  return showDialog(
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
                          Navigator.pop(context);
                          showDialog(
                            context: context, 
                            builder: (context){
                              final controller = TextEditingController();
                              return AlertDialog(
                                alignment: Alignment.center,
                                title: const Text("Title"),
                                content: TextField(
                                  controller: controller,
                                  onSubmitted: (val){
                                    var time = DateTime.now().toString().replaceAll(":", "-");
                                    var title = "untitled";
                                    if(val.isNotEmpty){
                                      title = val;
                                    }
                                    PageNode pageNode = PageNode(
                                      rows: RowMap(
                                        rows: {
                                        },
                                      ),
                                      pathNumber_1: -1, // means not connected to journey
                                      pathNumber_2: -1, // means not connected to journey
                                      t: 0, 
                                      pageNumber: -1, // means not connected to journey
                                      metadata: "fileName=$time;title=$title;backgroundColor=${Colors.white.value.toString()}",
                                    );
                                    Future.microtask(()async{
                                      await getFile("pageNode/$time");
                                      await writeFile("pageNode/$time", jsonEncode(pageNode.toJson()));
                                      final myModel = Provider.of<CustomProvider>(context, listen: false);
                                      myModel.pageNodes.add(pageNode);
                                      Navigator.pushNamed(context, "/pageEditor",arguments: {"node":pageNode,"path":"pageNode/$time"});
                                    });
                                  },
                                ),
                              );
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
                          Navigator.pop(context);
                          showDialog(
                            context: context, 
                            builder: (context){
                              final controller = TextEditingController();
                              return AlertDialog(
                                alignment: Alignment.center,
                                title: const Text("Title"),
                                content: TextField(
                                  controller: controller,
                                  onSubmitted: (val){
                                    var title = "untitled";
                                    if(val.isNotEmpty){
                                      title = val;
                                    }
                                    var time = DateTime.now().toString().replaceAll(":", "-");
                                    MediaNode mediaNode = MediaNode(
                                      pathNumber_1: -1, // means not connected to journey
                                      pathNumber_2: -1, // means not connected to journey
                                      t: 0, 
                                      text: "write",
                                      medialLink: "customUrl/",
                                      mediaHeight: 300,
                                      mediaNumber: -1, // means not connected to journey
                                      metadata: "fileName=$time;title=$title",
                                    );
                                    Future.microtask(()async{
                                      await getFile("mediaNode/$time");
                                      await writeFile("mediaNode/$time", jsonEncode(mediaNode.toJson()));
                                      final myModel = Provider.of<CustomProvider>(context, listen: false);
                                      myModel.mediaNodes.add(mediaNode);
                                      Navigator.pushNamed(context, "/mediaEditor",arguments: {"node":mediaNode,"path":"mediaNode/$time"});
                                    });
                                  }
                                )
                              );
                        });
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        );
}


void moveElement(List list, int currentIndex, int newIndex) {
  if (currentIndex < 0 || currentIndex >= list.length || 
      newIndex < 0 || newIndex >= list.length) {
    // throw RangeError('Indices are out of bounds.');
    return;
  }
  
  final element = list.removeAt(currentIndex);
  
  list.insert(newIndex, element);
}
