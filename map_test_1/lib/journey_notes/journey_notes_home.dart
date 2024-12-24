

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
    var totalItems = pageNodes.length;
    return ListView.builder(
      itemCount: totalItems,
      itemBuilder: (context,index){
        var path = 'pageNode/${pageNodes[index].metadata.split(";")[0].split("=")[1]}';
        return ListTile(
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
    var totalItems = mediaNodes.length;
    return ListView.builder(
      itemCount: totalItems,
      itemBuilder: (context,index){
        var path = 'mediaNode/${mediaNodes[index]!.metadata.split(";")[0].split("=")[1]}';
        return ListTile(
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
    return ListView.builder(
      itemCount: journeys.length,
      itemBuilder: (context,index){
        final temp = journeys[index];
        // print(temp.metadata);
        final title = temp!.metadata.split(";")[0].split("=")[1];
        return ListTile(
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
                                setState(() {
                                  var t = journeys[index].toJson();
                                  writeFile("journey/${journeys[index].name}/metadata", jsonEncode(t));
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
                                    await deleteDirRecursive("$journeyPath/${journeys[index].name}");
                                    journeys.removeAt(index);
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