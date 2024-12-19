import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helper_classes/customMarkdown.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';
import 'package:map_test_1/helpers_funcs/image_video_funcs.dart';
import 'package:map_test_1/pageEditors/video_player.dart';
import 'package:wheel_slider/wheel_slider.dart';

class PageEditor extends StatefulWidget {
  const PageEditor({super.key});
  final readOnly = false;

  @override
  State<PageEditor> createState() => _PageEditorState();
}

class _PageEditorState extends State<PageEditor> with WidgetsBindingObserver{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Color bgcolor = Colors.white;
  int editing = -1;
  RowMap rows = RowMap(rows: {});
  PageNode? pageNode;
  var focusNode = FocusNode();
  var path = "";

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }



  @override
  void dispose() {
    focusNode.dispose();    
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      if(path.isEmpty) return ;
      if(pageNode != null){
        var p = pageNode!.metadata.split(";");
        p[2] = "backgroundColor=${bgcolor.value.toString()}";
        pageNode!.metadata = p.join(";");
        var t = pageNode!.toJson();
        writeFile(path, jsonEncode(t));
        // pageNode/${pageNode!.metadata.split(";")[0].split("=")[1]}
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final args = arguments["node"];
    path = arguments["path"];
    if (args != null && rows != args) {
      pageNode = args as PageNode;
      rows = pageNode!.rows;
      var p = pageNode!.metadata.split(";");
      bgcolor = bgcolor == Colors.white ? Color(int.parse(p[2].split("=")[1])) : bgcolor;
      // print(pageNode!.rows.toJson());
    }
    int itemsLength = rows.rows.length;
    return PopScope(
      onPopInvokedWithResult: (b, val){
        if(pageNode != null){
          var p = pageNode!.metadata.split(";");
          p[2] = "backgroundColor=${bgcolor.value.toString()}";
          pageNode!.metadata = p.join(";");
          // print(p);
          var t = pageNode!.toJson();
          writeFile(path, jsonEncode(t));
          // pageNode/${pageNode!.metadata.split(";")[0].split("=")[1]}
        }

      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: appBarWidget(context),
        floatingActionButton: editing >= 0
        ? ElevatedButton(
          onPressed: (){
            editing = -1;
            setState(() {
              
            });
          }, 
          child: const Icon(Icons.check)
        ):
        const Icon(Icons.no_accounts,color: Colors.transparent,),
        body: GestureDetector(
          child: editorBody(context, itemsLength, rows),
          onTap: (){
            editing = -1;
            setState(() {
              
            });
          },
        ),
      ),
    );
  }




  Container editorBody(BuildContext context, int itemsLength, RowMap? rows) {
    return Container(
      decoration: BoxDecoration(color: bgcolor),
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: 1 + itemsLength,
          itemBuilder: (context, index) {
            const factor = 3.6;
            return index < itemsLength
                ? textMediaEditor(rows, rows!.rows.keys.toList()[index],index)
                : SizedBox(
                    height: 120,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        addElementButton(context, factor, "Text", () {
                          var t = DateTime.now();
                          rows!.rows[int.parse('${t.hour}${t.minute}${t.second}${t.millisecond}')] = "Write";
                          setState(() {});
                        }),
                        addElementButton(context, factor, "Media", () {
                          var t = DateTime.now();
                          rows!.rows[int.parse('${t.hour}${t.minute}${t.second}${t.millisecond}')] = "__5050__media__5050__ 120";
                          setState(() {});
                        }),
                        addElementButton(context, factor, "Link", () {}),
                      ],
                    ),
                  );
          }),
    );
  }

  SizedBox addElementButton(
      BuildContext context, double factor, String name, GestureTapCallback f) {
    return SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width / factor,
      child: TextButton(
        onPressed: f,
        child: Text(name),
      ),
    );
  }

  Widget textMediaEditor(RowMap? rows, int index, int indexPos) {
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
    var controller = TextEditingController();
    var b = (editing == index);
    controller.text = t;
    var keys = rows.rows.keys.toList();
    return GestureDetector(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                alignment: Alignment.center,
                title: const Text("Text"),
                content: SizedBox(
                  width: 40,
                  height: 64 * 3,
                  child: ListView(
                    children: [
                      if(indexPos-1 >= 0)
                      SizedBox(
                        width: 40,
                        child: ListTile(
                          title: const Text("Move Up"),
                          leading: const Icon(Icons.arrow_upward),
                          onTap: () {
                            moveMapEntry(rows.rows, keys[indexPos], keys[indexPos-1]);
                            // print(rows.rows);
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ),
                      if(indexPos+1 < keys.length)
                      SizedBox(
                        width: 40,
                        child: ListTile(
                          title: const Text("Move Down"),
                          leading: const Icon(Icons.arrow_downward),
                          onTap: () {
                            moveMapEntry(rows.rows,keys[indexPos], keys[indexPos+1]);
                            // print(rows.rows);
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: ListTile(
                          title: const Text("Delete"),
                          leading: const Icon(Icons.delete),
                          onTap: () {
                            rows.rows.remove(index);
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
      },
      onTap: (){
        editing = index;
        setState(() {
          
        });
      },
      child: Container(
          width: MediaQuery.of(context).size.width-16,
          padding: const EdgeInsets.only(top: 8.0),
          decoration: BoxDecoration(color: bgcolor),
          child: b
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
                  // focusNode: focusNode,
                  onChanged: (value){
                    rows.rows[index] = value;
                  },
                )
              : CustomMarkdown(
                  data: t,
                )),
    );
  }

  GestureDetector mediaRow(
      bool b2, double width, double height, bool b1, String parsedT, int index, int indexPos) {
      var keys = rows.rows.keys.toList();
      var t1 = parsedT.split("/");
      t1.removeAt(0);
      var t2 = t1.join("/");
      var isImage = t2.endsWith(".jpg")||t2.endsWith(".png")||t2.endsWith(".gif")||t2.endsWith(".jpeg")||t2.endsWith(".bmp")||t2.endsWith(".webp");
      // print(parsedT);
    return GestureDetector(
        onTap: () {
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
                              mediaSourcesDialogs(context, captureImage, captureVideo, index);
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
                              mediaSourcesDialogs(context, compressImage, compressVideo, index);
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
                              uoloadLinkFunc(context, index);
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
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  alignment: Alignment.center,
                  title: const Text("Media"),
                  content: SizedBox(
                    width: 40,
                    height: 64*4,
                    child: ListView(
                      children: [
                        SizedBox(
                          width: 40,
                          child: ListTile(
                            title: const Text("Height"),
                            leading: const Icon(Icons.compress),
                            onTap: () {
                              Navigator.pop(context);
                              heightAdjudtMedia(context, height, index);
                              
                            },
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: ListTile(
                            title: const Text("Delete"),
                            leading: const Icon(Icons.delete),
                            onTap: () {
                              rows.rows.remove(index);
                              setState(() {
                                Navigator.pop(context);
                              });
                            },
                          ),
                        ),
                        if(indexPos-1 >= 0)
                        SizedBox(
                          width: 40,
                          child: ListTile(
                            title: const Text("Move Up"),
                            leading: const Icon(Icons.arrow_upward),
                            onTap: () {
                              moveMapEntry(rows.rows, keys[indexPos], keys[indexPos-1]);
                              // print(rows.rows);
                              setState(() {
                                Navigator.pop(context);
                              });
                            },
                          ),
                        ),
                        if(indexPos+1 < keys.length)
                        SizedBox(
                          width: 40,
                          child: ListTile(
                            title: const Text("Move Down"),
                            leading: const Icon(Icons.arrow_downward),
                            onTap: () {
                              moveMapEntry(rows.rows,keys[indexPos], keys[indexPos+1]);
                              // print(rows.rows);
                              setState(() {
                                Navigator.pop(context);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
        child: b2
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
            )
            );
  }

  Future<dynamic> heightAdjudtMedia(BuildContext context, double height, int index) {
    return showDialog(
    barrierColor: Colors.transparent,
    context: context, 
    builder: (context){
      return AlertDialog(
        backgroundColor: Colors.white54,
        content: WheelSlider(
          totalCount: 5000, 
          isInfinite: false,
          initValue: height, 
          isVibrate: false,
          enableAnimation: false,
          onValueChanged: (value){
            var p = rows.rows[index]!.split(" ");
            if(p.length > 2){
              p[2] = value.toString();
              setState(() {
                rows.rows[index] = p.join(" ");
              });
            }
          }
        ),
      );
    });
  }

  Future<dynamic> uoloadLinkFunc(BuildContext context, int index) {
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
                var p = rows.rows[index]!.split(" ");
                if(p.length == 2){
                  p.insert(0,v);
                }else if(p.length > 2){
                  p[0] = v;
                }
                rows.rows[index] = p.join(" ");
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

  Future<dynamic> mediaSourcesDialogs(BuildContext context,Function funcImage, funcVideo, int index) {
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
                      var p = rows.rows[index]!.split(" ");
                      if(p.length == 2){
                        p.insert(0,"customUrl/media/images/${targetPath.split("/").last}");
                      }else if(p.length > 2){
                        p[0] = "customUrl/media/images/${targetPath.split("/").last}";
                      }
                      rows.rows[index] = p.join(" ");
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
                      var p = rows.rows[index]!.split(" ");
                      if(p.length == 2){
                        p.insert(0,"customUrl/media/videos/${targetPath.split("/").last}");
                      }else if(p.length > 2){
                        p[0] = "customUrl/media/videos/${targetPath.split("/").last}";
                      }
                      rows.rows[index] = p.join(" ");
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
      actions: [
        IconButton(
            onPressed: () {
              showDialog(
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
                                title: const Text("Background Color"),
                                leading: const Icon(Icons.color_lens),
                                onTap: () {
                                  Navigator.pop(context);
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        var c1 = bgcolor;
                                        return AlertDialog(
                                          content: MaterialColorPicker(
                                            onColorChange: (v) {
                                              c1 = Color.fromRGBO(
                                                  v.red,
                                                  v.green,
                                                  v.blue,
                                                  v.alpha / 255);
                                            },
                                            selectedColor: Colors.white,
                                            colors: const [
                                              Colors.red,
                                              Colors.yellow,
                                              Colors.lightGreen,
                                              Colors.grey,
                                              Colors.amber,
                                              Colors.cyan,
                                              Colors.brown,
                                              Colors.indigo,
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  bgcolor = c1;
                                                  setState(() {});
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("Submit"))
                                          ],
                                        );
                                      });
                                },
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: ListTile(
                                title: const Text("Font"),
                                leading: const Icon(Icons.font_download),
                                onTap: () {},
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  });
            },
            icon: const Icon(Icons.more_vert))
      ],
    );
  }

  
}
