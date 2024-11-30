import 'package:asset_editor/animation_editor.dart';
import 'package:asset_editor/helper_funcs.dart';
import 'package:asset_editor/tile_editor.dart';
import 'package:flutter/material.dart';
import 'package:asset_editor/provider.dart';
import 'package:asset_editor/home.dart';
import 'package:asset_editor/provider.dart';
import 'package:asset_editor/animation.dart';
import 'package:asset_editor/tiles.dart';
import 'package:provider/provider.dart';
import 'package:asset_editor/constants.dart';

void main() {

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CustomProvider())],
      child: const MainApp()
    )
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});


  @override
  State<MainApp> createState() => _MainAppState();

}

class _MainAppState extends State<MainApp>{

  @override
  void initState() {
    Future.microtask(() async{
      final myModel = Provider.of<CustomProvider>(context, listen: false);                                          
      var p = await classifyFiles();
      myModel.addFiles(p);
      await palletteLoadCsv();
      // print(colorPallettes);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(files.isNotEmpty){
      
    }

    if(width == 0){
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    }

    return MaterialApp(
      title: 'Asset Editor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Home(),
      routes: {
        "/animation": (context) => AnimationHome(),
        "/tiles": (context) => const TilesHome(),
        "/animation_editor": (context) => AnimationEditor(),
        "/tile_editor": (context) => const TileEditor(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}


