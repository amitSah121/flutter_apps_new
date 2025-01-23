

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';
import 'package:map_test_1/helpers_funcs/misselenious.dart';
import 'package:map_test_1/provider/provider.dart';
import 'package:provider/provider.dart';

class JourneyNotesHome extends StatefulWidget{
  const JourneyNotesHome({super.key});

  @override
  State<JourneyNotesHome> createState() => _JourneyNotesHomeState();
}

class _JourneyNotesHomeState extends State<JourneyNotesHome>{
  var journeys = [];
  var controller = TextEditingController();
  var resultsPageNodes = [];
  var resultsMediaNodes = [];
  var resultsJourneys = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async{
      final myModel = Provider.of<CustomProvider>(context, listen: false);
      journeys = myModel.journeys;
      setState(() {
        
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: appbar(),
          body: TabBarView(
            children: [
              journeyWidget(context),
              pageNodes(context),
              mediaNodes(context),
            ],
          ),
        ),
    );
  }

  Widget pageNodes(context){
    final myModel = Provider.of<CustomProvider>(context, listen: false);
    var pageNodes =  myModel.pageNodes;
    // var totalItems = pageNodes.length;
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

  Widget mediaNodes(context){
    final myModel = Provider.of<CustomProvider>(context, listen: false);
    var mediaNodes = myModel.mediaNodes;
    // var totalItems = mediaNodes.length;
    int i1 = -1;
    if(resultsMediaNodes.isEmpty){
      resultsMediaNodes = mediaNodes.map((k){
        i1++;
        return i1;
      }).toList();
    }
    // print(resultsMediaNodes);
    return ListView.builder(
      itemCount: resultsMediaNodes.length+1,
      itemBuilder: (context,index1){
        var index2 = index1 - 1 ;
        var index = index2 >=0 ? resultsMediaNodes[index2] : 0;
        var path;
        if(resultsMediaNodes.length > 0){
          path = 'mediaNode/${mediaNodes[index].metadata.split(";")[0].split("=")[1]}';
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
              resultsMediaNodes = [];
              if(v.isEmpty){
                int i=-1;
                resultsMediaNodes = mediaNodes.map((k){
                  i++;
                  return i;
                }).toList();
                setState(() {
                  
                });
                return;
              }
              int i=0;
              for(var p1 in mediaNodes){
                var t = p1.metadata.toLowerCase();
                t += ";${p1.text.toLowerCase()}";
                if(t.contains(v.toLowerCase())){
                  resultsMediaNodes.add(i);
                }
                i++;
              }
              setState(() {
                
              });
            },
          ),
        )
        :ListTile(
          leading: Text("${(index+1).toString()}.",style: const TextStyle(fontSize: 16),),
          title: Text(mediaNodes[index].metadata.split(";")[1].split("=")[1]),
          onTap: (){
            Future.microtask(()async{
              await Navigator.pushNamed(context, "/mediaEditor",arguments: {"node":mediaNodes[index],"path":path});
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
                          controller.text = mediaNodes[index].metadata.split(";")[1].split("=")[1];
                          return AlertDialog(
                            alignment: Alignment.center,
                            title: const Text("Rename"),
                            content: TextField(
                              controller: controller,
                              onChanged: (value) {
                                var p1 = mediaNodes[index].metadata.split(";");
                                p1[1] = "title=$value";
                                mediaNodes[index].metadata = p1.join(";");
                                // print(mediaNodes[])
                              },
                              onSubmitted: (value){
                                setState(() {
                                  var t = mediaNodes[index].toJson();
                                  writeFile("mediaNode/${mediaNodes[index].metadata.split(";")[0].split("=")[1]}", jsonEncode(t));
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
                                    await deleteFile("mediaNode/${mediaNodes[index].metadata.split(";")[0].split("=")[1]}");
                                    mediaNodes.removeAt(index);
                                    resultsMediaNodes = mediaNodes.map((k){
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
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.book),text: "Journey"),
              Tab(icon: Icon(Icons.pages_sharp), text: "Pages",),
              Tab(icon: Icon(Icons.image), text: "Medias",),
            ],
          ),
        title: const Text(appname),
        actions: [
          IconButton(
            onPressed: (){

            }, 
            icon: const Icon(Icons.notifications)
          ),
          IconButton(
            onPressed: ()async {
              await createPageMediaNode(context, setState);
            }, 
            icon: const Icon(Icons.add)
          )
        ],
        );
  }
  
  journeyWidget(BuildContext context) {
    int i1 = -1;
    if(resultsJourneys.isEmpty){
      resultsJourneys = journeys.map((k){
        i1++;
        return i1;
      }).toList();
    }
    return ListView.builder(
      itemCount: resultsJourneys.length + 1,
      itemBuilder: (context,index1){
        var index2 = index1 - 1 ;
        var index = index2 >=0 ? resultsJourneys[index2] : 0;
        var title = " ";
        final temp;
        if(resultsJourneys.length > 0){
          temp = journeys[index];
          // print(temp.metadata);
          title = temp!.metadata.split(";")[0].split("=")[1];
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
              resultsJourneys = [];
              if(v.isEmpty){
                int i=-1;
                resultsJourneys = journeys.map((k){
                  i++;
                  return i;
                }).toList();
                setState(() {
                  
                });
                return;
              }
              int i=0;
              for(Journey p1 in journeys){
                var t = p1.metadata.toLowerCase();
                for(var q1 in p1.pageNodes){
                  t += ";${q1.metadata};${q1.toJson().toString().toLowerCase()}";
                }
                for(var q1 in p1.mediaNodes){
                  t += ";${q1.metadata};${q1.toJson().toString().toLowerCase()}";
                }
                if(t.contains(v.toLowerCase())){
                  resultsJourneys.add(i);
                }
                i++;
              }
              setState(() {
                
              });
            },
          ),
        )
        :ListTile(
          leading: Text("${(index+1).toString()}.",style: const TextStyle(fontSize: 16),),
          title: Text(title),
          trailing: journeys[index]!.metadata.split(";")[1].split("=")[1] == "none" ? const Icon(Icons.circle) : const Icon(Icons.accessibility_rounded),
          onTap: (){
            final myModel = Provider.of<CustomProvider>(context, listen: false);
            var tempJ = myModel.currentJourney;
            myModel.currentJourney = journeys[index];
            if(myModel.currentJourney!.metadata.split(";")[1].split("=")[1] == "none"){
              Future.microtask(()async{
                await Navigator.pushNamed(context, "/manualEditor");
                myModel.currentJourney = tempJ;
                // print("result = $result");
              });
            }else{
              Future.microtask(()async{
                myModel.currentJourney = journeys[index];
                await Navigator.pushNamed(context, "/tracer");
                // print("result = $result");
              });
            }
          },
          onLongPress: (){
            showBottomSheet(
              context: context, 
              builder: (context){
                return Wrap(children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.imagesearch_roller),
                    title: const Text("View As Story"),
                    onTap: (){
                      Navigator.pop(context);
                      Future.microtask(()async{
                        await Navigator.pushNamed(context, "/viewAsStory",arguments: {"node":journeys[index]});
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text(' Rename'),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context, 
                        builder: (context){
                          var controller = TextEditingController();
                          controller.text = journeys[index].metadata.split(";")[0].split("=")[1];
                          return AlertDialog(
                            alignment: Alignment.center,
                            title: const Text("Rename"),
                            content: TextField(
                              controller: controller,
                              onChanged: (value) {
                                var p1 = journeys[index].metadata.split(";");
                                p1[0] = "title=$value";
                                journeys[index].metadata = p1.join(";");
                                // print(mediaNodes[])
                              },
                              onSubmitted: (value){
                                Navigator.pop(context);
                                setState(() async {
                                  var t = journeys[index].toJson();
                                  await writeFile("journey/${journeys[index].name}/metadata", jsonEncode(t));
                                  
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
                                    await deleteDirRecursive("$journeyPath/${journeys[index].name}");
                                    journeys.removeAt(index);
                                    resultsJourneys = journeys.map((k){
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



  
}