import 'dart:io';

import 'package:flutter/material.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helper_classes/customMarkdown.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/pageEditors/video_player.dart';

class PageReader extends StatefulWidget {
  PageReader({super.key});
  PageNode? pageNode;
  @override
  State<PageReader> createState() => _PageReaderState();
}

class _PageReaderState extends State<PageReader> {
  Color bgcolor = Colors.white;
  RowMap rows = RowMap(rows: {});
  // PageNode? pageNode;


  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final args = arguments["node"];
    if (args != null && rows != args && args.runtimeType.toString() == "PageNode") {
      widget.pageNode = args as PageNode;
      rows = widget.pageNode!.rows;
      var p = widget.pageNode!.metadata.split(";");
      bgcolor = bgcolor == Colors.white ? Color(int.parse(p[2].split("=")[1])) : bgcolor;
      // print(widget.pageNode!.rows.toJson());
    }else if(widget.pageNode != null){
      rows = widget.pageNode!.rows;
      var p = widget.pageNode!.metadata.split(";");
      bgcolor = bgcolor == Colors.white ? Color(int.parse(p[2].split("=")[1])) : bgcolor;
    }
    int itemsLength = rows.rows.length;
    return Scaffold(
      appBar: appBarWidget(context),
      body: readerBody(context, itemsLength, rows),
    );
  }




  Container readerBody(BuildContext context, int itemsLength, RowMap? rows) {
    return Container(
      decoration: BoxDecoration(color: bgcolor),
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: itemsLength,
          itemBuilder: (context, index) {
            return textMediaReader(rows, rows!.rows.keys.toList()[index],index);
          }),
    );
  }


  Widget textMediaReader(RowMap? rows, int index, int indexPos) {
    // var t = "# Hello \n## Fello \n I am **the** don \n and then \n|This is|The best that I can say about|\n|1|2|";
    var t = rows!.rows[index]!;
    var b = t.contains("__5050__media__5050__");
    var b1 = t.startsWith("customUrl/");
    var b2 = t.split(" ").length == 2 && t.split(" ")[0] == "__5050__media__5050__";
    var parsedT = t.split(" ")[0];
    double width = deviceWidth - 16, height = 300;
    if (!b2 && b) {
      height = double.parse(t.split(" ")[2]);
    }
    return b ? mediaRow(b2, width, height, b1, parsedT, index, indexPos) : textRow(t,index, indexPos);
    // Text(rows!.rows[index+1]!,style: const TextStyle(fontSize: 16),)
  }


  void moveMapEntry<K, V>(Map<int, V> map, int currentIndex, int newIndex) {
    var entry_1 = map[currentIndex];
    var temp = map[newIndex];
    map[newIndex]= entry_1!;
    map[currentIndex] = temp!;

  }


  Widget textRow(String t, int index, indexPos) {
    return Container(
        width: MediaQuery.of(context).size.width-16,
        padding: const EdgeInsets.only(top: 8.0),
        decoration: BoxDecoration(color: bgcolor),
        child: CustomMarkdown(
                data: t,
              ));
  }

  Widget mediaRow(
      bool b2, double width, double height, bool b1, String parsedT, int index, int indexPos) {
      var t1 = parsedT.split("/");
      t1.removeAt(0);
      var t2 = t1.join("/");
      var isImage = t2.endsWith(".jpg")||t2.endsWith(".png")||t2.endsWith(".gif")||t2.endsWith(".jpeg")||t2.endsWith(".bmp")||t2.endsWith(".webp");
      // print(parsedT);
    return b2
        ? Padding(
            padding: const EdgeInsets.only(top: 8),
          child: Container(
              decoration: const BoxDecoration(color: Colors.grey),
              width: width,
              height: height,
            ),
        )
        : Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top:8),
              child: (isImage
                ? ( !b1 ?
                  Image.network(
                    parsedT,
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File("$defaultAppPath/$t2"),
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                  )
                )
                :
                VideoDisplay(
                  b1: b1,
                  parsedT: parsedT,
                  t2: t2,
                  defaultAppPath: defaultAppPath,
                  width: width,
                  height: height,
                )
              )
            ),
            if(t2.contains("live_"))
            const Positioned(
              top: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.radio_button_checked,color: Colors.red,),
              )
            ),
          ]
        );
  }


  AppBar appBarWidget(BuildContext context) {
    return AppBar(
      title: const Text(appname),
    );
  }

  
}
