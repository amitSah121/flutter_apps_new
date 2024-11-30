import 'dart:io';

import 'package:asset_editor/helper_classes.dart';
import 'package:flutter/material.dart';
import 'package:asset_editor/constants.dart';
import 'dart:convert';

class CustomProvider extends ChangeNotifier {

  var animationFiles = [];
  var tileFiles = [];
  List<SpriteData>? currentAnimation;
  List<TileData>? currentTile;

  // Future<void> set_auth(us, pa) async{
  //   // username = us;
  //   // password = pa;
  //   notifyListeners();
  // }

  void addFiles(p){
    for(var p1 in p['animation']!){
        animationFiles.add(p1);
      }
      for(var p1 in p['tiles']!){
        tileFiles.add(p1);
      }
  }

}