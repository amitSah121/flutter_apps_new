import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';

class CustomProvider extends ChangeNotifier {
  List<Journey> journeys = [];
  List<PageNode> pageNodes = [];
  List<MediaNode> mediaNodes = [];
  // String defaultAppPath = "";

  // Future<void> set_auth(us, pa) async{
  //   // username = us;
  //   // password = pa;
  //   notifyListeners();
  // }

  // void addFiles(p){
  //   for(var p1 in p['animation']!){
  //       animationFiles.add(p1);
  //     }
  //     for(var p1 in p['tiles']!){
  //       tileFiles.add(p1);
  //     }
  // }

  Future<void> loadJourney()async{
    journeys = [];
    var journeyDirs = await listFilesDirs(dir: "journey", pattern: "*");
    for(var q in journeyDirs){
      var p = Journey(q.split("/").last);
      await p.fillVariables();
      journeys.add(p);
    }
  }

  Future<void> loadOtherNodes()async{
    pageNodes = [];
    mediaNodes = [];
    var pn = await listFilesDirs(dir: "pageNode", pattern: "*");
    for(var q in pn){
      var t = await readFile("pageNode/${q.split("/").last}");
      print(t);
      var p = jsonDecode(t);
      pageNodes.add(PageNode.fromJson(p));
    }

    var mn = await listFilesDirs(dir: "mediaNode", pattern: "*");
    for(var q in mn){
      var p = jsonDecode(await readFile("mediaNode/${q.split("/").last}"));
      mediaNodes.add(MediaNode.fromJson(p));
    }
  }

  void printFiles(){
    for(var q in journeys){
      for(var p1 in q.pathNodes){
        print(p1.toCsvRow());
      }

      for(var p1 in q.pageNodes){
        print(p1.toJson());
      }

      for(var p1 in q.mediaNodes){
        print(p1.toJson());
      }
    }
    
  }

  

}