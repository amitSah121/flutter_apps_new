import 'dart:io';

import 'package:asset_editor/constants.dart';
import 'package:asset_editor/helper_classes.dart';
import 'package:asset_editor/helper_funcs.dart';
import 'package:asset_editor/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimationHome extends StatefulWidget {
  @override
  _AnimationHomeState createState() => _AnimationHomeState();
}

class _AnimationHomeState extends State<AnimationHome> {
  List<Map<String, dynamic>> animationData = [];

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  void loadFiles() async {
    Future.microtask(() async {
      final myModel = Provider.of<CustomProvider>(context, listen: false);
      var p1 = myModel.animationFiles;

      final List<Map<String, dynamic>> tempData = [];

      for (File file in p1) {
        // print(file);
        final fileInfo = file;
        tempData.add({
          'title': fileInfo.uri.pathSegments.last.replaceAll('.csv', ''),
          'image': null,
          'modified': fileInfo.lastModifiedSync(),
          'file': fileInfo
        });
      }

      setState(() {
        animationData = tempData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appTheme_1,
        title: const Text(
          "Animation Home",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: animationData.length + 1,
          itemBuilder: (context, index) {
            if(index == animationData.length){
              return SizedBox(
                
                  child: ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text("New Animation"),
                  onTap: (){

                    var temp = TextEditingController();
                      showDialog(context: context, builder: (context){
                        return AlertDialog(
                          title: const Text("New Animation"),
                          content: TextField(
                            controller: temp,
                            decoration: const InputDecoration(hintText: ""),
                          ),
                          actions: [
                            TextButton(
                              onPressed: (){
                                Future.microtask(() async {
                                  final myModel = Provider.of<CustomProvider>(context, listen: false);
                                  var p1 = myModel;
                                  if(temp.text.isNotEmpty){
                                    final a1 = await getCsvFile('animation_${temp.text}');
                                    writeCsvAnim('animation_${temp.text}', List<SpriteData>.empty());
                                    if(a1.path.isNotEmpty){
                                      p1.currentAnimation = await readCsvAnim('animation_${temp.text}');
                                      p1.animationFiles.add(a1);
                                      Navigator.pushNamed(context, "/animation_editor",arguments: {'title':'animation_${temp.text}'});
                                    }
                                  }
                                  setState((){
                                    loadFiles();
                                  });
                                });
                                
                                Navigator.of(context).pop();
                              },
                              child: const Text("Submit")
                            ),
                            TextButton(
                              onPressed: (){
                                Navigator.of(context).pop();
                              }, 
                              child: const Text("Cancel")
                            )
                          ],
                        );
                      });

                    

                  },
                )
              );
            }else{
              final animation = animationData[index];
              // print("hh");
              return SizedBox(
                width: 50,
                height: 350,
                child: GestureDetector(
                  onTap: (){
                    Future.microtask(()async{
                      var myModel = Provider.of<CustomProvider>(context,listen: false);
                      myModel.currentAnimation = await readCsvAnim(animation['title']);
                      // print({myModel.currentAnimation,animation['title']});
                      Navigator.pushNamed(context, "/animation_editor",arguments : animationData[index]);
                  });
                  },
                   
                  onLongPress: (){
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Wrap(
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.delete),
                              title: const Text(' Delete'),
                              onTap: () {
                                Future.microtask(() async {
                                  final myModel = Provider.of<CustomProvider>(context, listen: false);
                                  var p1 = myModel;
                                  p1.animationFiles.remove(animation['file']);
                                  p1.currentAnimation = null;
                                  animationData.remove(animation);
                                  deleteCsvFile(animation['title']);
                                  // loadFiles();
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                });
                              }
                            ),
                          ]
                        );
                      }
                    );
                    
                  },
                  child: Card(
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: animation['image'] != null
                                ? Image.file(
                                    animation['image'],
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.animation,
                                    size: 60,
                                    color: Colors.grey[700],
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            animation['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Modified: ${animation['modified']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
