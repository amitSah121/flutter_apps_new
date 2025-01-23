

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:page_editor/file_funcs.dart';
import 'package:page_editor/misseleneous.dart';
import 'package:page_editor/provider.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget{
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>{
  var controller = TextEditingController();
  var resultsPageNodes = [];
  
  @override
  void initState() {
    super.initState();
    // final myModel = Provider.of<CustomProvider>(context, listen: false);
    // resultsPageNodes = myModel.pageNodes;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: appbar(),
      body: pageNodes_(context)
    );
  }

  Widget pageNodes_(context){
    final myModel = Provider.of<CustomProvider>(context, listen: false);
    var pageNodes =  myModel.pageNodes;
    int i1 = -1;
    if(resultsPageNodes.isEmpty){
      resultsPageNodes = pageNodes.map((k){
        i1++;
        return i1;
      }).toList();
    }
    return ListView.builder(
      itemCount: resultsPageNodes.length+1,
      itemBuilder: (context,index1){
        var index2 = index1 - 1 ;
        var index = index2 >=0 ? resultsPageNodes[index2] : 0;
        var path;
        if(resultsPageNodes.length > 0){
          path = 'pageNode/${pageNodes[index].metadata.split(";")[0].split("=")[1]}';
        }
        return index1 == 0? 
        Container(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black.withAlpha(10)),borderRadius: const BorderRadius.all(Radius.circular(16))),
              hintText: 'Search Text ...', // Hint text without a border
            ),
            onSubmitted: (v){
              resultsPageNodes = [];
              if(v.isEmpty){
                int i=-1;
                resultsPageNodes = pageNodes.map((k){
                  i++;
                  return i;
                }).toList();
                setState(() {
                  
                });
                return;
              }
              int i=0;
              for(var p1 in pageNodes){
                var t = p1.metadata.toLowerCase();
                for(var q1 in p1.rows.rows.values){
                  t += ";${q1.toLowerCase()}";
                }
                if(t.contains(v.toLowerCase())){
                  resultsPageNodes.add(i);
                }
                i++;
              }
              setState(() {
                
              });
            },
          ),
        )
        :ListTile(
          leading: Text("${(index+1).toString()}.",style: const TextStyle(fontSize: 16),), // number
          title: Text(pageNodes[index].metadata.split(";")[1].split("=")[1]), // title
          onTap: (){
            Future.microtask(()async{
              await Navigator.pushNamed(context, "/pageEditor",arguments: {"node":pageNodes[index],"path":path});
              setState(() {
                
              });
            });
          },
          onLongPress: (){
            showBottomSheet(
              context: context, 
              builder: (context){
                return Wrap(children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text(' Rename'),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context, 
                        builder: (context){
                          var controller = TextEditingController();
                          controller.text = pageNodes[index].metadata.split(";")[1].split("=")[1];
                          return AlertDialog(
                            alignment: Alignment.center,
                            title: const Text("Rename"),
                            content: TextField(
                              controller: controller,
                              onChanged: (value) {
                                var p1 = pageNodes[index].metadata.split(";");
                                p1[1] = "title=$value";
                                pageNodes[index].metadata = p1.join(";");
                              },
                              onSubmitted: (value){
                                setState(() {
                                  var t = pageNodes[index].toJson();
                                  writeFile("pageNode/${pageNodes[index].metadata.split(";")[0].split("=")[1]}", jsonEncode(t));
                                  Navigator.pop(context);
                                });
                              },
                            ),
                          );
                        }
                      );
                    }
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text(' Delete'),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            title: const Text('Delete node?'),
                            children: [
                              SimpleDialogOption(
                                onPressed: (){
                                  Future.microtask(()async{
                                    await deleteFile("pageNode/${pageNodes[index].metadata.split(";")[0].split("=")[1]}");
                                    pageNodes.removeAt(index);
                                    resultsPageNodes = pageNodes.map((k){
                                      i1++;
                                      return i1;
                                    }).toList();
                                    setState(() {
                                      Navigator.pop(context);
                                    });
                                  });
                                },
                                child: const Text('Ok'),
                              ),
                              SimpleDialogOption(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                            ],
                          );
                        },
                      );

                    }
                  ),
                ]);
              }
            );
          },
          
        );
      });
  }

  AppBar appbar() {
    return AppBar(
        title: const Text("PageEditor"),
        actions: [
          IconButton(
            onPressed: ()async {
              await pageNodeCreate(context,setState);
            }, 
            icon: const Icon(Icons.add)
          )
        ],
        );
  }

  
}