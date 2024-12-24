import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_test_1/constants/constants.dart';
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

Future<dynamic> createPageMediaNode(BuildContext context, setState) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          alignment: Alignment.topRight,
          title: const Text("Create"),
          content: SizedBox(
            width: 40,
            height: 64*3,
            child: ListView(
              children: [
                dialogOptions(context,"Page", const Icon(Icons.book), pageNodeCreate, setState),
                dialogOptions(context,"Media", const Icon(Icons.photo), mediaNodeCreate, setState),
                dialogOptions(context,"Journey", const Icon(Icons.auto_graph), addJourney, setState),
              ],
            ),
          ),
        );
      });
}

SizedBox dialogOptions(BuildContext context, String optionText, icon, func, setState) {
  return SizedBox(
                width: 40,
                child: ListTile(
                  title: Text(optionText),
                  leading: icon,
                  onTap: () {
                    Navigator.pop(context);
                    func(context, setState);
                  },
                ),
              );
}

Future<dynamic> addJourney(context,setState) {
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
                    temp.metadata = "title=$title;autopathDone=none";
                    Future.microtask(() async {
                      await getDir("$journeyPath/$time");
                      await getFile("$journeyPath/$time/pathNode.json");
                      await getFile("$journeyPath/$time/pageNode.json");
                      await getFile("$journeyPath/$time/mediaNode.json");
                      await writeFile(
                          "$journeyPath/$time/metadata", temp.metadata);
                      await Navigator.pushNamed(context, "/tracer");
                      setState((){});
                    });
                  }));
        });
  }

Future<dynamic> mediaNodeCreate(BuildContext context, setState) {
  return showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
            alignment: Alignment.center,
            title: const Text("Title"),
            content: TextField(
                controller: controller,
                onSubmitted: (val) async {
                  Navigator.pop(context);
                  var title = "untitled";
                  if (val.isNotEmpty) {
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
                }));
      });
}

Future<dynamic> pageNodeCreate(BuildContext context, setState) {
  return showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          alignment: Alignment.center,
          title: const Text("Title"),
          content: TextField(
            controller: controller,
            onSubmitted: (val) async {
              Navigator.pop(context);
              var time = DateTime.now().toString().replaceAll(":", "-");
              var title = "untitled";
              if (val.isNotEmpty) {
                title = val;
              }
              PageNode pageNode = PageNode(
                rows: RowMap(
                  rows: {},
                ),
                pathNumber_1: -1, // means not connected to journey
                pathNumber_2: -1, // means not connected to journey
                t: 0,
                pageNumber: -1, // means not connected to journey
                metadata:
                    "fileName=$time;title=$title;backgroundColor=${Colors.white.value.toString()}",
              );
              await Future.microtask(() async {
                await getFile("pageNode/$time");
                await writeFile(
                    "pageNode/$time", jsonEncode(pageNode.toJson()));
                final myModel =
                    Provider.of<CustomProvider>(context, listen: false);
                myModel.pageNodes.add(pageNode);
                await Navigator.pushNamed(context, "/pageEditor",
                    arguments: {"node": pageNode, "path": "pageNode/$time"});
                setState(() {});
              });
            },
          ),
        );
      });
}

void moveElement(List list, int currentIndex, int newIndex) {
  if (currentIndex < 0 ||
      currentIndex >= list.length ||
      newIndex < 0 ||
      newIndex >= list.length) {
    // throw RangeError('Indices are out of bounds.');
    return;
  }

  final element = list.removeAt(currentIndex);

  list.insert(newIndex, element);
}
