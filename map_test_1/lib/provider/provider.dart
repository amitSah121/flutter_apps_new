import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';

class CustomProvider extends ChangeNotifier {
  List<Journey> journeys = [];
  List<PageNode> pageNodes = [];
  List<MediaNode> mediaNodes = [];
  Journey ? currentJourney;
  String username = "";
  String password = "";


  Future<void> loadJourney()async{
    journeys = [];
    var journeyDirs = await listFilesDirs(dir: journeyPath, pattern: "*");
    for(var q in journeyDirs){
      try{
        var p = Journey(q.split("/").last);
        await p.fillVariables();
        journeys.add(p);
      }catch (e){}
    }
  }

    Future<void> set_auth(us, pa) async{
      username = us;
      password = pa;
      notifyListeners();
    }


  Future<void> loadOtherNodes()async{
    pageNodes = [];
    mediaNodes = [];
    var pn = await listFilesDirs(dir: "pageNode", pattern: "*");
    for(var q in pn){
      try{
        var t = await readFile("pageNode/${q.split("/").last}");
        // print(t);
        var p = jsonDecode(t);
        pageNodes.add(PageNode.fromJson(p));
      }catch (e){}
    }

    var mn = await listFilesDirs(dir: "mediaNode", pattern: "*");
    for(var q in mn){
      try{
        var t = await readFile("mediaNode/${q.split("/").last}");
        // print(t);
        var p = jsonDecode(t);
        mediaNodes.add(MediaNode.fromJson(p));
      }catch (e){}
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