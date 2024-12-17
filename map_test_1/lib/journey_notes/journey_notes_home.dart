

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';
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
              const Icon(Icons.directions_bike),
            ],
          ),
        ),
    );
  }

  Widget pageNodes(context){
    final myModel = Provider.of<CustomProvider>(context, listen: false);
    var pageNodes =  myModel.pageNodes;
    var mediaNodes = myModel.mediaNodes;
    var totalItems = pageNodes.length+mediaNodes.length;
    return ListView.builder(
      itemCount: totalItems,
      itemBuilder: (context,index){
        return index < pageNodes.length ? 
        ListTile(
          leading: Text("${(index+1).toString()}.",style: const TextStyle(fontSize: 16),),
          title: Text(pageNodes[index].metadata.split(";")[1].split("=")[1]), // title
          onTap: (){
            Navigator.pushNamed(context, "/pageEditor",arguments: pageNodes[index]);
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
          
        )
        :
        ListTile(
          leading: Text("${(index-pageNodes.length+1).toString()}.",style: const TextStyle(fontSize: 16),),
          title: Text(mediaNodes[index-pageNodes.length].metadata.split(";")[1].split("=")[1]),
          onTap: (){
            Navigator.pushNamed(context, "/mediaEditor",arguments: mediaNodes[index-pageNodes.length]);
          },
          
        );;
      });
  }

  AppBar appbar() {
    return AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.book),text: "Journey"),
              Tab(icon: Icon(Icons.pages_sharp), text: "Pages",),
              Tab(icon: Icon(Icons.photo), text: "Gallary",)
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
            onPressed: (){

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
        final temp = journeys[index].name;
        final toRemove = temp.split(" ").last;
        final name = temp.substring(0,temp.length-toRemove.length-1);
        return ListTile(
          leading: Text("${(index+1).toString()}.",style: const TextStyle(fontSize: 16),),
          title: Text(name),
          onTap: (){
            Navigator.pushNamed(context, "/home",arguments: journeys[index]);
          },
          
        );
      });
  }



  
}