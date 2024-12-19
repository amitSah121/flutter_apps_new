import 'package:flutter/material.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helper_classes/helperClasses.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';
import 'package:map_test_1/helpers_funcs/misselenious.dart';
import 'package:map_test_1/mapscreen/mapscreen.dart';
import 'package:map_test_1/provider/provider.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var result = 'Search...';
  var map = MapScreen();
  Journey? searchResult;
  bool openRightDrawer = false;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if(args != null){
      searchResult = args as Journey;
      result = searchResult!.metadata.split(";")[0].split("=")[1];
      map.pathNodes = searchResult!.pathNodes;
      map.pageNodes = searchResult!.pageNodes;
      map.mediaNodes = searchResult!.mediaNodes;
      map.goMyLoc = false;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: appBarWidget(context),
      drawer: appDrawer(),
      body: Stack(children: [
        map,
        Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: ListTile(
            leading: result == "Search..."
                ? const Icon(Icons.search)
                : const Icon(Icons.circle_outlined),
            title: Text(result),
            onTap: () {
              Navigator.pushNamed(context, "/search");
            },
          ),
        ),
        if (searchResult != null && openRightDrawer) // this is to implement altitude
        Positioned(
          right: 0,
          top: 100,
          child:  Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(16))),
            width: noteDisplaySize[0],
            height: MediaQuery.of(context).size.height*0.5,
            child: ListView.builder(
              itemCount: map.pageNodes!.length+map.mediaNodes!.length,
              itemBuilder: (context,index){
                return (index < map.pageNodes!.length) ? 
                ListTile(
                  title: const Text("Pages"),
                  leading: const Icon(Icons.book),
                  onTap: (){
                    Navigator.pushNamed(context,"/pageReader",arguments: map.pageNodes![index]);
                  },
                )
                :
                ListTile(
                  title: const Text("Media"),
                  leading: const Icon(Icons.photo),
                  onTap: (){
                    Navigator.pushNamed(context,"/mediaReader",arguments: map.mediaNodes![index - map.pageNodes!.length]);
                  },
                )
                ; 
              }),
          ),
        ),
        if(!openRightDrawer && searchResult != null)
        Positioned(
          right: 0,
          top: 100,
          child:  Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(16)), border: Border(left: BorderSide(color: Colors.black,width: 3),)),
            width: noteDisplaySize[1],
            height: MediaQuery.of(context).size.height*0.5,
          )
        ),
        if (searchResult != null) // this is to implement altitude
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        height: 64,
                        width: MediaQuery.of(context).size.width,
                        child: Column(children: [
                          drawAltitude(MediaQuery.of(context).size.width*0.9, 64)// made for having different icons in column
                        ]))
                  ],
                )),
          ),
      ]),
      floatingActionButton: floatingActionWidget(),
      bottomNavigationBar: bottomBarDraw(),
    );
  }

  CustomPaint drawAltitude(double width, double height) {
    List<double> xes = generateEvenlySpaced(0, width, searchResult!.pathNodes.length);
    int i=-1;
    List<Offset> offsets = searchResult!.pathNodes.map((p){
      i++;
      return Offset(xes[i], p.altitude);
    }).toList();
    return CustomPaint(
      size: Size(width, height), // Define the size of the canvas
      painter: LinePainter(
        offsets
      ), 
      );
  }

  AppBar appBarWidget(BuildContext context) {
    return AppBar(
      title: const Text(appname),
      leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu)),
      actions: [
        IconButton(
          onPressed: () {
            Future.microtask(() async {
              try {
                // await deleteFile("pageNode/2024-12-17 16-25-45.090136");
                // await deleteFile("pageNode/2024-12-18 19-42-59.584421");
                // await deleteFile("mediaNode/2024-12-18 19-42-59.584421");
                // await deleteFile("pageNode/[fileName, 2024-12-17 16-25-45.090136]");
                // await listFilesDirs(dir: "", pattern: "*/*/*");
                // await listFilesDirs(dir: "pageNode",pattern: "*/*");
                // await listFilesDirs(dir: "mediaNode",pattern: "*/*");
                // print(await readFile("pageNode/2024-12-18 20-37-05.015187"));
                // await deleteFile("mediaNode/2024-12-18 20-37-05.015187");
                await listFilesDirs(dir:"journey", pattern: "*/*/*");
              } catch (e) {
                print(e);
              }
            });

            // Navigator.pushNamed(context, "/notifications");
          },
          icon: const Icon(Icons.notifications)),
        IconButton(
          onPressed: (){
            createPageMediaNode(context);
          }, 
          icon: const Icon(Icons.add)
        )  
      ],
    );
  }

  Padding floatingActionWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 56),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(24))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                map.goMyLoc = true;
                map.getLocation();
              },
              icon: const Icon(Icons.assistant_navigation),
              iconSize: 48,
            ),
            if(searchResult != null)
            IconButton(
              onPressed: (){
                openRightDrawer = !openRightDrawer;
                setState(() {
                  
                });
              }, 
              icon: Icon(!openRightDrawer ? Icons.menu_open : Icons.close),
              iconSize: 36,
            )
          ],
        ),
      ),
    );
  }

  Drawer appDrawer() {
    var keys = drawerConstHome.keys.toList();
    return Drawer(
        child: ListView.builder(
            itemCount: keys.length,
            itemBuilder: (ctx, index) {
              return drawerElement(
                  label: keys[index],
                  press: () {
                    drawerElementFuncs(index);
                  },
                  icon: Icon(drawerConstHome[keys[index]]));
            }));
  }

  void drawerElementFuncs(index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, "/journey_notes");
        break;
      case 1:
        Navigator.pushNamed(context, "/settings");
        break;
    }
  }

  ListTile drawerElement(
      {required label, required VoidCallback press, required icon}) {
    return ListTile(
      leading: icon,
      title: TextButton(
        onPressed: press,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(label),
        ),
      ),
    );
  }

  BottomNavigationBar bottomBarDraw() {
    var keys = bottomNavBarHome.keys.toList();
    final myModel = Provider.of<CustomProvider>(context, listen: false);
    final which2 = myModel.currentJourney == null ? 0 : 1;
    return BottomNavigationBar(
      items: keys.map((ele) {
        return bottomNavBarHome[ele].runtimeType == ([Icons.all_out]).runtimeType ?
        BottomNavigationBarItem(
          icon: Icon((bottomNavBarHome[ele]! as List<IconData>)[which2]),
          label: ele.split("/")[which2],
        )
        :
        BottomNavigationBarItem(
          icon: Icon(bottomNavBarHome[ele] as IconData),
          label: ele,
        );
      }).toList(),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      onTap: (index) {
        bottomBarElementFuncs(index,which2);
      },
    );
  }

  void bottomBarElementFuncs(index, which2) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, "/explore");
        break;
      case 1:

        if(which2 == 1){
          Navigator.pushNamed(context, "/tracer");
        }else{
          showDialog(
            context: context, 
            builder: (context){
              final controller = TextEditingController();
              return AlertDialog(
                alignment: Alignment.center,
                title: const Text("Title"),
                content: TextField(
                  controller: controller,
                  onSubmitted: (val){
                    Navigator.pop(context);
                    var title = "untitled";
                    if(val.isNotEmpty){
                      title = val;
                    }
                    
                    final myModel = Provider.of<CustomProvider>(context, listen: false);
                    var time = DateTime.now().toString().replaceAll(":", "-");
                    Journey temp = Journey(time);
                    myModel.currentJourney = temp;
                    temp.metadata = "title=$title;autopathDone=false";
                    Future.microtask(()async{
                      await getDir("journey/$time");
                      await getFile("jouney/$time/pathNode.json");
                      await getFile("jouney/$time/pageNode.json");
                      await getFile("jouney/$time/mediaNode.json");
                      Navigator.pushNamed(context, "/tracer");
                    });
                  }
                )
              );
            });
        }
        break;
      case 3:
        Navigator.pushNamed(context, "/profile");
        break;
    }
  }
}
