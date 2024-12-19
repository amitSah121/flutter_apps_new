

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helper_classes/customMarkdown.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/pageEditors/video_player.dart';

class MediaReader extends StatefulWidget{
  const MediaReader({super.key});
  @override
  State<MediaReader> createState() => _MediaReaderState();
}

class _MediaReaderState extends State<MediaReader>{
  MediaNode? mediaNode;
  bool editing = false;

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final args = arguments["node"];
    if (args != null && mediaNode != args) {
      mediaNode = args as MediaNode;
      // print(pageNode!.rows.toJson());
    }

    var b1 = true;
    double width = deviceWidth - 16, height = 300;
    var isImage = true;
    var link = "";
    var t2 = "";

    if(mediaNode != null){
      link = mediaNode!.medialLink;
      b1 = link.startsWith("customUrl/");
      height = mediaNode!.mediaHeight;

      var t1 = link.split("/");
      t1.removeAt(0);
      t2 = t1.join("/");
      isImage = t2.endsWith(".jpg")||t2.endsWith(".png")||t2.endsWith(".gif")||t2.endsWith(".jpeg")||t2.endsWith(".bmp")||t2.endsWith(".webp");
    }
    // print({isImage, t2, link});
    
    return Scaffold(
      appBar: appBarWidget(context),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8),
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              mediaWidget(context, link, width, height, isImage, b1, t2),
              textRow(mediaNode == null ? "Write" : mediaNode!.text)
            ]
          ),
        )
      )
    ); 
  }

  Widget textRow(String t) {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(top: 8.0),
        decoration: const BoxDecoration(color: Colors.white),
        child: CustomMarkdown(
          data: t,
        ));
  }

  Widget mediaWidget(BuildContext context, String link, double width, double height, bool isImage, bool b1, String t2) {
    return link == "customUrl/"
      ? 
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          decoration: const BoxDecoration(color: Colors.grey),
          width: width,
          height: height,
        ),
      )
      :
      Stack(
        children: [
          Padding(
          padding: const EdgeInsets.only(top:8),
          child: isImage
            ? ( !b1 ?
              Image.network(
                link,
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
              parsedT: link,
              t2: t2,
              defaultAppPath: defaultAppPath,
              width: width,
              height: height,
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