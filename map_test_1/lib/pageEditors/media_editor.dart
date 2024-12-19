

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helper_classes/customMarkdown.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';
import 'package:map_test_1/helpers_funcs/image_video_funcs.dart';
import 'package:map_test_1/pageEditors/video_player.dart';
import 'package:wheel_slider/wheel_slider.dart';

class MediaEditor extends StatefulWidget{
  const MediaEditor({super.key});
  final readOnly = false;

  @override
  State<MediaEditor> createState() => _MediaEditorState();
}

class _MediaEditorState extends State<MediaEditor> with WidgetsBindingObserver{

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MediaNode? mediaNode;
  bool editing = false;
  var path = "";

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      if(path.isEmpty) return ;
      if(mediaNode != null){
          var t = mediaNode!.toJson();
          writeFile(path, jsonEncode(t));
          // "mediaNode/${mediaNode!.metadata.split(";")[0].split("=")[1]}"
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final args = arguments["node"];
    path = arguments["path"];
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
    
    return PopScope(
      onPopInvokedWithResult: (b, val){
        if(mediaNode != null){
          // print(p);
          var t = mediaNode!.toJson();
          // print(t);
          writeFile(path, jsonEncode(t));
          // "mediaNode/${mediaNode!.metadata.split(";")[0].split("=")[1]}"
        }

      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: appBarWidget(context),
        floatingActionButton: editing 
        ? ElevatedButton(
          onPressed: (){
            editing = false;
            setState(() {
              
            });
          }, 
          child: const Icon(Icons.check)
        ):
        const Icon(Icons.no_accounts,color: Colors.transparent,),
        body: GestureDetector(
          child: SingleChildScrollView(
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
          ),
          onTap: (){
            editing = false;
            setState(() {
              
            });
          },
        )
      ),
    ); 
  }

  Widget textRow(String t) {
    var controller = TextEditingController();
    var focusNode = FocusNode();
    controller.text = t;
    return GestureDetector(
      onTap: (){
        editing = true;
        setState(() {
          
        });
      },
      child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(top: 8.0),
          decoration: const BoxDecoration(color: Colors.white),
          child: editing
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black.withAlpha(10))),
                    hintText: 'Write', // Hint text without a border
                  ),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  cursorColor: Colors.black,
                  readOnly: widget.readOnly,
                  maxLines: null,
                  onChanged: (value){
                    mediaNode?.text = value;
                  },
                  onTapOutside: (v){
                    setState(() {
                      focusNode.unfocus();
                    });
                  },
                )
              : CustomMarkdown(
                  data: t,
                )),
    );
  }

  GestureDetector mediaWidget(BuildContext context, String link, double width, double height, bool isImage, bool b1, String t2) {
    return GestureDetector(
      onTap: (){
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                alignment: Alignment.center,
                title: const Text("Media"),
                content: SizedBox(
                  width: 40,
                  height: 64*3,
                  child: ListView(
                    children: [
                      SizedBox(
                        width: 40,
                        child: ListTile(
                          title: const Text("Camera"),
                          leading: const Icon(Icons.camera),
                          onTap: () {
                            Navigator.pop(context);
                            mediaSourcesDialogs(context, captureImage, captureVideo);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: ListTile(
                          title: const Text("Local Folder"),
                          leading: const Icon(Icons.folder),
                          onTap: () {
                            Navigator.pop(context);
                            mediaSourcesDialogs(context, compressImage, compressVideo);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: ListTile(
                          title: const Text("Upload"),
                          leading: const Icon(Icons.upload),
                          onTap: () {
                            Navigator.pop(context);
                            uoloadLinkFunc(context);
                          },
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
      },
      onLongPress: (){
        heightAdjudtMedia(context);
      },
      child:
      link == "customUrl/"
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
        )
    );
  }

  Future<dynamic> heightAdjudtMedia(BuildContext context) {
    return showDialog(
    barrierColor: Colors.transparent,
    context: context, 
    builder: (context){
      return AlertDialog(
        backgroundColor: Colors.white54,
        content: WheelSlider(
          totalCount: 5000, 
          isInfinite: false,
          initValue: mediaNode!.mediaHeight.toInt(), 
          isVibrate: false,
          enableAnimation: false,
          onValueChanged: (value){
            mediaNode!.mediaHeight = (value as int).toDouble();
            setState(() {
              
            });
          }
        ),
      );
    });
  }

  Future<dynamic> uoloadLinkFunc(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context){
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text("Link"),
          content: TextField(
            controller: controller,
            onSubmitted: (v){
              Future.microtask(()async{
                if(!(isImageUrl(v)) || !(isVideoUrl(v))){
                  Navigator.pop(context);
                  return;
                }
                mediaNode?.medialLink = v; 
                setState(() {
                  
                });
                Navigator.pop(context);
              });
            },
          ),
        );
      }
    );
  }

  Future<dynamic> mediaSourcesDialogs(BuildContext context,Function funcImage, funcVideo) {
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: const Text("Media Type"),
          content: SizedBox(
            width: 120,
            height: 64*2,
            child: ListView(
              children: [
                SizedBox(
                  width: 120,
                  height: 64,
                  child: ListTile(
                    leading: const Icon(Icons.image),
                    title: const Text("Image"),
                    onTap: () async{
                      final targetPath = await funcImage();
                      if(targetPath == "none"){
                        Navigator.pop(context);
                        return;
                      }
                      mediaNode?.medialLink = "customUrl/media/images/${targetPath.split("/").last}";
                      setState(() {
                        
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(
                  width: 120,
                  height: 64,
                  child: ListTile(
                    leading: const Icon(Icons.videocam),
                    title: const Text("Videos"),
                    onTap: () async{
                      final targetPath = await funcVideo();
                      // print(targetPath);
                      if(targetPath == "none"){
                        Navigator.pop(context);
                        return;
                      }
                      mediaNode?.medialLink = "customUrl/media/videos/${targetPath.split("/").last}";
                      setState(() {
                      });
                      Navigator.pop(context);
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

  AppBar appBarWidget(BuildContext context) {
    return AppBar(
      title: const Text(appname),
    );
  }
}