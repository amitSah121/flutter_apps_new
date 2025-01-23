import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:page_editor/file_funcs.dart';
import 'package:page_editor/model.dart';

class CustomProvider extends ChangeNotifier {
  List<PageNode> pageNodes = [];

  Future<void> loadOtherNodes()async{
    pageNodes = [];
    var pn = await listFilesOnly(dir: "pageNode");
    for(var q in pn){
      try{
        var t = await readFile("pageNode/${q.split("/").last}");
        // print(t);
        var p = jsonDecode(t);
        pageNodes.add(PageNode.fromJson(p));
      }catch (e){}
    }
  }

  

}