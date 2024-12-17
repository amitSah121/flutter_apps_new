import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helper_classes/customMarkdown.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';
import 'package:wheel_slider/wheel_slider.dart';

class PageEditor extends StatefulWidget {
  const PageEditor({super.key});
  final readOnly = false;

  @override
  State<PageEditor> createState() => _PageEditorState();
}

class _PageEditorState extends State<PageEditor> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Color bgcolor = Colors.white;
  int editing = -1;
  RowMap rows = RowMap(rows: {});
  PageNode? pageNode;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
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
          writeFile("pageNode/${pageNode!.metadata.split(";")[0].split("=")[1]}", jsonEncode(t));
        }

      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: appBarWidget(context),
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

  Future<String> _compressImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if(image == null) return "none";
    final targetPath = "${await localPath}/media/images/${image.path.split("/").last}";

    await FlutterImageCompress.compressAndGetFile(
      image.path,
      targetPath,
      quality: 60, // Adjust compression quality (0-100)
    );

    return targetPath;
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
                ? textMediaEditor(rows, rows!.rows.keys.toList()[index])
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

  Widget textMediaEditor(RowMap? rows, int index) {
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
    return b ? mediaRow(b2, width, height, b1, parsedT, index) : textRow(t,index);
    // Text(rows!.rows[index+1]!,style: const TextStyle(fontSize: 16),)
  }

  Widget textRow(String t, int index) {
    var controller = TextEditingController();
    var focusNode = FocusNode();
    var b = (editing == index);
    controller.text = t;
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
                  height: 64 * 2,
                  child: ListView(
                    children: [
                      SizedBox(
                        width: 40,
                        child: ListTile(
                          title: const Text("Move To"),
                          leading: const Icon(Icons.change_history),
                          onTap: () {},
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
                  onChanged: (value){
                    rows.rows[index] = value;
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

  GestureDetector mediaRow(
      bool b2, double width, double height, bool b1, String parsedT, int index) {
      var t1 = parsedT.split("/");
      t1.removeAt(0);
      var t2 = t1.join("/");
      var isImage = t2.endsWith(".jpg")||t2.endsWith(".png")||t2.endsWith(".gif");
      // print(isImage);
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
                            onTap: () {},
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: ListTile(
                            title: const Text("Local Folder"),
                            leading: const Icon(Icons.folder),
                            onTap: () {
                              Navigator.pop(context);
                              showDialog(
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
                                                final targetPath = await _compressImage();
                                                var p = rows.rows[index]!.split(" ");
                                                if(p.length == 2){
                                                  p.insert(0,"customUrl/media/images/${targetPath.split("/").last}");
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
                                              leading: const Icon(Icons.image),
                                              title: const Text("Videos"),
                                              onTap: () async{
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
                            },
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: ListTile(
                            title: const Text("Upload"),
                            leading: const Icon(Icons.upload),
                            onTap: () {},
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
                    height: 64*2,
                    child: ListView(
                      children: [
                        SizedBox(
                          width: 40,
                          child: ListTile(
                            title: const Text("Height"),
                            leading: const Icon(Icons.compress),
                            onTap: () {
                              Navigator.pop(context);
                              showDialog(
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
                                        if(p.length >= 2){
                                          p[2] = value.toString();
                                          setState(() {
                                            rows.rows[index] = p.join(" ");
                                          });
                                        }
                                      }
                                    ),
                                  );
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
        child: b2
            ? Padding(
                padding: const EdgeInsets.only(top: 8),
              child: Container(
                  decoration: const BoxDecoration(color: Colors.grey),
                  width: width,
                  height: height,
                ),
            )
            : (isImage
                ? ( !b1 ?
                  Image.network(
                    parsedT,
                    width: width,
                    height: height,
                  )
                : Image.file(
                    File("$defaultAppPath/$t2"),
                    width: width,
                    height: height,
                  )
                )
                :
                const Text("Vodep")
              )
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
