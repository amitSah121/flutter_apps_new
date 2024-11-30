import 'dart:async';
import 'dart:math';

import 'package:asset_editor/animation_canvas.dart';
import 'package:asset_editor/constants.dart';
import 'package:asset_editor/helper_classes.dart';
import 'package:asset_editor/helper_funcs.dart';
import 'package:asset_editor/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class AnimationEditor extends StatefulWidget {
  AnimationEditor({super.key});

  @override
  State<AnimationEditor> createState() => _AnimationEditorState();
}

class Character {
  List<Frame> frame = [Frame()];
  String name = "Default";
  int currentFrame = 0;
}

class _AnimationEditorState extends State<AnimationEditor> {
  int frames = 1;
  int currentCharacterSelection = 0;
  var currentSelectedWidget = 2;
  var characters = [];
  var canvas = EditorCanvas();
  var isPlaying = false;
  var frameRate = 5;
  Timer? timer;
  String? title ;
  int? num_chars = 0;

  @override
  void initState() {
    Future.microtask(()async{
      var myModel = Provider.of<CustomProvider>(context, listen: false);
      var name = "";
      var frame = -1;
      Character? i1;
      Frame? i2;
      for(var p in myModel.currentAnimation!){
        if(p == null) break;
        // print(p.name);
        if(name != p.name){
          name = p.name;
          i1 = Character();
          i1.name = p.name;
          // print({p.name, i1.name});
          characters.add(i1); 
          // print("hello"); 
          
          frame = p.frame;
          i2 = i1.frame[0];
        }
        if(frame != p.frame){
          frame = p.frame;
          i2 = Frame();
          i1?.frame.add(i2);
          // print("Hello");
        }
        
        if(p.id.contains("rect")){
          var r1 = RectangleShape(x:p.x.toDouble(), y: p.y.toDouble(), 
            width: p.width.toDouble(), height: p.height.toDouble(),rotation:  p.rotation.toDouble(), fillColor: hexToColor(p.fillColor), strokeColor: hexToColor(p.strokeColor))..rbl=p.rbl..rbr=p.rbr..rtl=p.rtl..rtr=p.rtr;
          i2?.shapes.add(r1 as Shape);
          // print({"rect",p.id, p.frame,p.name});
        }else if(p.id.contains("oval")){
          var r1 = CircleShape(x:p.x.toDouble(), y: p.y.toDouble(), 
            width: p.width.toDouble(), height: p.height.toDouble(),rotation:  p.rotation.toDouble(), fillColor: hexToColor(p.fillColor), strokeColor: hexToColor(p.strokeColor))..rbl=p.rbl..rbr=p.rbr..rtl=p.rtl..rtr=p.rtr;
          i2?.shapes.add(r1 as Shape);
          // print({"oval",p.id, p.frame,p.name});

        }    
      }
      // characters.removeLast();
      setState(() {
        // print(characters);
        if(characters.isEmpty){
          characters.add(Character());
        }
        canvas.frame = characters[0].frame;
        frames = canvas.frame.length;
        canvas.setChildState((){});
      });
    });
    // canvas.frame = characters[0].frame;
    super.initState();
  }

  int computeTotalElements() {
    int total = 0;

    for (var rows in colorPallettes.values) {
      for (var colors in rows) {
        total += colors.length;
      }
    }

    return total;
  }

  int computeTotalElementsIn(name) {
    int total = 0;

    for (int i = 0; i < colorPallettes.keys.length; i++) {
      if (colorPallettes.keys.elementAt(i) == name) {
        for (var _ in colorPallettes[name]!) {
          total += 1;
        }
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {

    
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    title = arguments['title'];
    const double toolSpacing = 16.0;
    return WillPopScope(
      onWillPop: ()async{
        Future.microtask(() async{
          var my_Model = Provider.of<CustomProvider>(context,listen: false);
          var i1 = 0;
          List<SpriteData> s1 = [];
          for(var p in characters){
            var i2 = 0;
            for(var q in p.frame){
              for(var r in q.shapes){
                var t1 = "rect_";
                if(r is RectangleShape){
                  t1 = "rect_";
                }else{
                  t1 = "oval_";
                }  
                var s2 = SpriteData(name: p.name, id: '$t1$i1', x: r.x.toInt(), y: r.y.toInt(), width: r.width.toInt(), height: r.height.toInt(), rotation: r.rotation.toInt(), frame: i2, fillColor: colorToHex(r.fillColor), strokeColor: colorToHex(r.strokeColor), rtl: r.rtl, rtr: r.rtr, rbl: r.rbl, rbr: r.rbr);
                i1++;
                s1.add(s2);
              }
              i2++;
            }
          }
          // my_Model.currentAnimation = s1;
          // print(s1);
          await writeCsvAnim(title!, s1);
        });
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            
            backgroundColor: appTheme_1,
            title: const Text(
              "Animation Editor",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              settingsUi(context),
            ],
          ),
          body: Row(
            children: [
              // Left Panel
              Container(
                child: SizedBox(
                  width: 64,
                  height: MediaQuery.of(context).size.height,
                  child: ListView(
                    children: [
                      _toolButton("Rectangle", Icons.crop_square, () {
                        canvas.addShape("rect");
                      }, onLongPressed: () {
                        if (canvas.selectedShape != null) {
                          showDialog(
                              barrierColor: Colors.transparent,
                              context: context,
                              builder: (context) {
                                var p1 = canvas.selectedShape;
                                var m = max(p1!.width / 2, p1.height / 2);
                                return StatefulBuilder(
                                    builder: (context, setStateDialog) {
                                  return AlertDialog(
                                    backgroundColor: Colors.transparent,
                                    content: SizedBox(
                                      height: 400,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("TopLeft"),
                                          Slider(
                                              label: p1.rtl.toString(),
                                              value: p1.rtl.toDouble(),
                                              min: 0,
                                              max: m,
                                              divisions: m.toInt(),
                                              onChanged: (p) {
                                                p1.changeCornerRadius(
                                                    p.toInt(), -1, -1, -1);
                                                canvas.setChildState(() {});
                                                setStateDialog(() {});
                                                setState(() {});
                                              }),
                                          const Text("TopRight"),
                                          Slider(
                                              label: p1.rtr.toString(),
                                              value: p1.rtr.toDouble(),
                                              min: 0,
                                              max: m,
                                              divisions: m.toInt(),
                                              onChanged: (p) {
                                                p1.changeCornerRadius(
                                                    -1, p.toInt(), -1, -1);
                                                canvas.setChildState(() {});
                                                setStateDialog(() {});
                                                setState(() {});
                                              }),
                                          const Text("BottomLeft"),
                                          Slider(
                                              label: p1.rbl.toString(),
                                              value: p1.rbl.toDouble(),
                                              min: 0,
                                              max: m,
                                              divisions: m.toInt(),
                                              onChanged: (p) {
                                                p1.changeCornerRadius(
                                                    -1, -1, p.toInt(), -1);
                                                canvas.setChildState(() {});
                                                setStateDialog(() {});
                                                setState(() {});
                                              }),
                                          const Text("TopRight"),
                                          Slider(
                                              label: p1.rbr.toString(),
                                              value: p1.rbr.toDouble(),
                                              min: 0,
                                              max: m,
                                              divisions: m.toInt(),
                                              onChanged: (p) {
                                                p1.changeCornerRadius(
                                                  -1,
                                                  -1,
                                                  -1,
                                                  p.toInt(),
                                                );
                                                canvas.setChildState(() {});
                                                setStateDialog(() {});
                                                setState(() {});
                                              }),
                                          const Text("All"),
                                          Slider(
                                              label: p1.rtl.toString(),
                                              value: p1.rtl.toDouble(),
                                              min: 0,
                                              max: m,
                                              divisions: m.toInt(),
                                              onChanged: (p) {
                                                p1.changeCornerRadius(
                                                    p.toInt(),
                                                    p.toInt(),
                                                    p.toInt(),
                                                    p.toInt());
                                                canvas.setChildState(() {});
                                                setStateDialog(() {});
                                                setState(() {});
                                              })
                                        ],
                                      ),
                                    ),
                                  );
                                });
                              });
                        }
                      }),
                      _toolButton("Oval", Icons.circle, () {
                        canvas.addShape("circle");
                      }),
                      const SizedBox(
                        height: toolSpacing,
                      ),
                      _toolButton("Multi-Select", Icons.select_all, () {
                        canvas.toggleMultiSelect(!canvas.isMultiSelectEnabled);
                        canvas.selectedShape = null;
                        canvas.setChildState(() {});
                        setState(() {});
                      }, selected: canvas.isMultiSelectEnabled),
                      _toolButton("Add", Icons.add_circle_outline, () {}),
                      _toolButton("Delete", Icons.delete_outline_rounded, () {
                        canvas.removeShape();
                      }),
                      _toolButton("Paste", Icons.paste, () {
                        for(var p in canvas.multiSelectedShapes){
                          canvas.frame[canvas.currentFrame].shapes.add(p.copyWith());
                        }
                      }),
                      const SizedBox(
                        height: toolSpacing,
                      ),
                      _toolButton("Translate", Icons.open_with, () {
                        canvas.setButtonState(0);
                        currentSelectedWidget = 2;
                        setState(() {});
                      }, selected: currentSelectedWidget == 2),
                      _toolButton("Rotate", Icons.rotate_right, () {
                        canvas.setButtonState(1);
                        currentSelectedWidget = 3;
                        setState(() {});
                      }, selected: currentSelectedWidget == 3),
                      _toolButton("Scale", Icons.zoom_out_map, () {
                        canvas.setButtonState(2);
                        currentSelectedWidget = 1;
                        setState(() {});
                      }, selected: currentSelectedWidget == 1),
                      const SizedBox(
                        height: toolSpacing,
                      ),
                      _toolButton("Fill", Icons.color_lens, () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: canvas.colorPallette.length * 25,
                                  height: 180,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            5, // Number of columns in the grid
                                        crossAxisSpacing:
                                            0.0, // Horizontal spacing between grid items
                                        mainAxisSpacing:
                                            0.0, // Vertical spacing between grid items
                                      ),
                                      itemCount: canvas.colorPallette.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              canvas.setFillColor(
                                                  canvas.colorPallette[index]);
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            width:
                                                25, // Can be omitted; GridView manages item dimensions
                                            height:
                                                30, // Can be omitted; GridView manages item dimensions
                                            decoration: BoxDecoration(
                                              color: canvas.colorPallette[index],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            });
                      }),
                      // _toolButton("Stroke", Icons.color_lens_outlined, () {
                      //   showDialog(
                      //       context: context,
                      //       builder: (context) {
                      //         return Dialog(
                      //           alignment: Alignment.centerLeft,
                      //           child: SizedBox(
                      //             width: canvas.colorPallette.length * 25,
                      //             height: 30,
                      //             child: ListView.builder(
                      //               scrollDirection: Axis.horizontal,
                      //               itemCount: canvas.colorPallette.length,
                      //               itemBuilder: (context, index) {
                      //                 return GestureDetector(
                      //                   onTap: () {
                      //                     setState(() {
                      //                       canvas.setStrokeColor(
                      //                           canvas.colorPallette[index]);
                      //                       // just_in++;
                      //                     });
                      //                     Navigator.pop(context);
                      //                   },
                      //                   child: Container(
                      //                     width: 25,
                      //                     height: 30,
                      //                     decoration: BoxDecoration(
                      //                         color: canvas.colorPallette[index]),
                      //                   ),
                      //                 );
                      //               },
                      //             ),
                      //           ),
                      //         );
                      //       });
                      // }),
                      const SizedBox(
                        height: toolSpacing,
                      ),
                      _toolButton("Layer Up", Icons.arrow_upward, () {
                        canvas.moveShapeLayerDown();
                      }),
                      _toolButton("Layer Down", Icons.arrow_downward, () {
                        canvas.moveShapeLayerUp();
                      }),
                      const SizedBox(
                        height: toolSpacing,
                      ),
                      _toolButton("Undo", Icons.undo, () {
                        canvas.undo();
                      }),
                      _toolButton("Redo", Icons.redo, () {
                        canvas.redo();
                      }),
                      const SizedBox(
                        height: toolSpacing,
                      ),
                      _toolButton(
                          "play", isPlaying ? Icons.pause : Icons.play_circle, () {
                        isPlaying = !isPlaying;
                        final frameDuration =
                            Duration(milliseconds: (1000 / frameRate).round());
                        if (isPlaying) {
                          timer = Timer.periodic(frameDuration, (_) {
                            canvas.currentFrame =
                                canvas.currentFrame < canvas.frame.length - 1
                                    ? canvas.currentFrame + 1
                                    : 0;
                            canvas.setChildState(() {});
                            setState(() {});
                          });
                        } else {
                          timer?.cancel();
                        }
                        setState(() {});
                      }),
                      // _toolButton("Copy", Icons.copy, () {
                      //   canvas.copiedShapes = [];
                      //   for(var p in canvas.multiSelectedShapes){
                      //     canvas.copiedShapes.add(p.copyWith());
                      //   }
                      // }),
                    ],
                  ),
                ),
              ),
      
              // Center Workspace
              Expanded(
                child: Container(
                  child: Center(
                    child: canvas,
                  ),
                ),
              ),
      
              // Right Panel
              Container(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: characters
                            .length, // Replace with dynamic character count
                        itemBuilder: (context, index) {
                          var p1 = "$index ${characters[index].name}";
                          if (p1.length > 10) {
                            p1 = '${p1.substring(0, 7)}...';
                          }
                          Color c1 = Colors.white;
                          Color c2 = Colors.black;
                          if (index == currentCharacterSelection) {
                            c1 = const Color.fromARGB(255, 14, 138, 113);
                            c2 = Colors.white;
                          }
                          return GestureDetector(
                            onLongPress: () {
                              if (index == currentCharacterSelection) {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Wrap(children: <Widget>[
                                        ListTile(
                                          leading: const Icon(Icons.delete),
                                          title: const Text(' Delete'),
                                          onTap: () {
                                            if (characters.length == 0) {
                                              Navigator.pop(context);
                                              return;
                                            }
                                            characters.removeAt(index);
                                            canvas.frame =
                                                characters[index - 1].frame;
                                            currentCharacterSelection = index - 1;
                                            frames = canvas.frame.length;
                                            canvas.setCurrentFrame(
                                                characters[index - 1]
                                                    .currentFrame);
                                            canvas.setChildState(() {});
                                            setState(() {});
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.edit),
                                          title: const Text(' Rename'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return StatefulBuilder(
                                                      builder: (context, _) {
                                                    var t =
                                                        TextEditingController();
                                                    t.text = characters[
                                                            currentCharacterSelection]
                                                        .name;
                                                    return AlertDialog(
                                                      content: SizedBox(
                                                        height: 100,
                                                        child: Column(
                                                          children: [
                                                            const Text("Rename"),
                                                            TextField(
                                                              controller: t,
                                                              onSubmitted: (p) {
                                                                Navigator.pop(
                                                                    context);
                                                                setState(() {
                                                                  characters[currentCharacterSelection]
                                                                          .name =
                                                                      t.text;
                                                                });
                                                              },
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  });
                                                });
                                          },
                                        ),
                                      ]);
                                    });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: c1,
                                  border: const Border(
                                      top: BorderSide(color: appTheme_1))),
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: TextButton(
                                child: Text(
                                  p1,
                                  style: TextStyle(color: c2),
                                ),
                                onPressed: () {
                                  characters[currentCharacterSelection]
                                      .currentFrame = canvas.currentFrame;
                                  currentCharacterSelection = index;
                                  canvas.frame =
                                      characters[currentCharacterSelection].frame;
                                  frames = canvas.frame.length;
                                  canvas.setCurrentFrame(
                                      characters[currentCharacterSelection]
                                          .currentFrame);
                                  canvas.setChildState(() {});
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.add, size: 32),
                      title: const Text("Add"),
                      onTap: () {
                        var p = Character();
                        p.name = "Default$num_chars";
                        num_chars = num_chars! + 1;
                        canvas.frame = p.frame;
                        characters.add(p);
                        currentCharacterSelection = characters.length - 1;
                        frames = canvas.frame.length;
                        canvas.currentFrame = 0;
                        canvas.setChildState(() {});
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
      
          // bottom panel
          bottomNavigationBar: SizedBox(
            height: 60,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: frames + 1,
                itemBuilder: (context, index) {
                  return index != frames
                      ? Container(
                          decoration: BoxDecoration(
                              color: (canvas.currentFrame == index
                                  ? Colors.grey.shade200
                                  : Colors.transparent)),
                          child: TextButton(
                            onPressed: () {
                              canvas.setCurrentFrame(index);
                              setState(() {});
                            },
                            onLongPress: () {
                              if (index != canvas.currentFrame) return;
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Wrap(children: <Widget>[
                                      ListTile(
                                        leading: const Icon(Icons.delete),
                                        title: const Text(' Delete'),
                                        onTap: () {
                                          canvas.removeFrame();
                                          frames--;
                                          setState(() {});
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.copy),
                                        title: const Text(' Copy'),
                                        onTap: () {
                                          canvas.copyFrame();
                                          setState(() {});
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.paste),
                                        title: const Text('Paste'),
                                        onTap: () {
                                          canvas.pasteFrame();
                                          setState(() {});
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.add),
                                        title: const Text('Left'),
                                        onTap: () {
                                          canvas.addFrameCurrent(left: true);
                                          frames++;
                                          setState(() {});
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.add),
                                        title: const Text('Right'),
                                        onTap: () {
                                          canvas.addFrameCurrent(left: false);
                                          frames++;
                                          setState(() {});
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ]);
                                  });
                            },
                            child: Text('$index'),
                          ),
                        )
                      : IconButton(
                          onPressed: () {
                            canvas.addFrame();
                            frames++;
                            setState(() {});
                          },
                          icon: const Icon(Icons.add));
                }),
          )),
    );
  }

  IconButton settingsUi(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, setState) {
                return AlertDialog(
                    title: const Text('Settings'),
                    alignment: Alignment.topRight,
                    content: SizedBox(
                      width: 60,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.speed),
                            title: Slider(
                              value: frameRate.toDouble(),
                              min: 1,
                              max: 60,
                              divisions: 59,
                              label: frameRate.round().toString(),
                              onChanged: (double value) {
                                setState(() {
                                  frameRate = value.toInt();
                                });
                              },
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.all_out),
                            title: Slider(
                              value: canvas.onionFrames.toDouble(),
                              min: 0,
                              max: 5,
                              divisions: 5,
                              label: canvas.onionFrames.round().toString(),
                              onChanged: (double value) {
                                setState(() {
                                  canvas.onionFrames = value.toInt();
                                  canvas.setChildState(() {});
                                });
                              },
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.grid_3x3),
                            title: const Text("Grid"),
                            trailing: Checkbox(
                              value: canvas.grid_on, 
                              onChanged: (p){
                                canvas.grid_on = p!;
                                canvas.setChildState((){});
                                setState((){});
                                Navigator.pop(context);
                            })
                          ),
                          ListTile(
                            title: const Text("Color Pallette"),
                            leading: const Icon(Icons.color_lens),
                            onTap: () {
                              Navigator.pop(context);
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    var total_elements = computeTotalElements();
                                    return AlertDialog(
                                      alignment: Alignment.topRight,
                                      content: SizedBox(
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height,
                                        child: ListView(children: [
                                          SizedBox(
                                              width: 250,
                                              height: total_elements * 30,
                                              child: Scrollbar(
                                                interactive: true,
                                                child: ListView.builder(

                                                    physics: NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        colorPallettes.keys.length,
                                                    itemBuilder: (context, index) {
                                                      var name = colorPallettes.keys
                                                          .elementAt(index);
                                                      var total_elements_in =
                                                          computeTotalElementsIn(
                                                              name);
                                                      return SizedBox(
                                                        width: 200,
                                                        height: (total_elements_in +
                                                                1) *
                                                            60,
                                                        child: ListView.builder(
                                                            physics: const NeverScrollableScrollPhysics(),
                                                            itemCount:
                                                                colorPallettes[
                                                                            name]!
                                                                        .length +
                                                                    1,
                                                            itemBuilder:
                                                                (context, index2) {
                                                              return index2 == 0
                                                                  ? Text(name)
                                                                  : SizedBox(
                                                                    // decoration: BoxDecoration(border: Border(bottom: BorderSide(color:Colors.black.withOpacity(0.3)))),
                                                                      width: 200,
                                                                      height: 50*((colorPallettes[name]![index2 - 1].length~/10)+1).toDouble(),
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap: () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          canvas.setColorPallette(colorPallettes[
                                                                                  name]![
                                                                              index2 -
                                                                                  1]);
                                                                        },
                                                                        child: GridView.builder(
                                                                            itemCount: colorPallettes[name]![index2 - 1].length,
                                                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                              crossAxisCount: 10
                                                                            ),
                                                                            // scrollDirection: Axis.horizontal,
                                                                            physics: const NeverScrollableScrollPhysics(),
                                                                            itemBuilder: (context, index3) {
                                                                              var item =
                                                                                  colorPallettes[name]![index2 - 1][index3];
                                                                              // print(item);
                                                                              return Container(
                                                                                decoration:
                                                                                    BoxDecoration(color: item),
                                                                                width:
                                                                                    30,
                                                                                height:
                                                                                    30,
                                                                              );
                                                                            }),
                                                                      ),
                                                                    );
                                                            }),
                                                      );
                                                    }),
                                              ))
                                        ]),
                                      ),
                                    );
                                  });
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.save),
                            title: const Text("Save"),
                            onTap: (){
                              Navigator.pop(context);
                              Future.microtask(() async{
                                var my_Model = Provider.of<CustomProvider>(context,listen: false);
                                var i1 = 0;
                                List<SpriteData> s1 = [];
                                for(var p in characters){
                                  var i2 = 0;
                                  for(var q in p.frame){
                                    for(var r in q.shapes){
                                      var t1 = "rect_";
                                      if(r is RectangleShape){
                                        t1 = "rect_";
                                      }else{
                                        t1 = "oval_";
                                      }  
                                      var s2 = SpriteData(name: p.name, id: '$t1$i1', x: r.x.toInt(), y: r.y.toInt(), width: r.width.toInt(), height: r.height.toInt(), rotation: r.rotation.toInt(), frame: i2, fillColor: colorToHex(r.fillColor), strokeColor: colorToHex(r.strokeColor), rtl: r.rtl, rtr: r.rtr, rbl: r.rbl, rbr: r.rbr);
                                      i1++;
                                      s1.add(s2);
                                    }
                                    i2++;
                                  }
                                }
                                my_Model.currentAnimation = s1 as List<SpriteData>;
                                // print(s1);
                                writeCsvAnim(title!, s1);
                              });
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.book),
                            title: const Text("Manual"),
                            onTap: (){
                              Navigator.pop(context);
                              showDialog(
                                context: context, 
                                builder: (context){
                                  return AlertDialog(
                                    content: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.height,
                                      child: ListView(
                                        children: [
                                          Image.asset("assets/images/manual.png")
                                        ]),
                                    ),
                                  );
                              });
                            },
                          ),
                        ],
                      ),
                    ));
              });
            });
      },
      icon: const Icon(Icons.settings),
    );
  }

  Widget _toolButton(String label, IconData icon, VoidCallback onPressed,
      {onLongPressed, bool selected = false}) {
    return Container(
      decoration: BoxDecoration(
          color: selected ? Colors.grey.shade300 : Colors.transparent),
      child: TextButton(
        onPressed: onPressed,
        onLongPress: onLongPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 30),
        ),
      ),
    );
  }
}
