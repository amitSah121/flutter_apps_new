import 'dart:async';
import 'package:flutter/material.dart';
import 'package:page_editor/file_funcs.dart';
import 'package:page_editor/home.dart';
import 'package:page_editor/page_editor.dart';
import 'package:page_editor/provider.dart';
import 'package:provider/provider.dart';


@pragma('vm:entry-point')



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
    super.initState();
    Future.microtask(() async{
      final myModel = Provider.of<CustomProvider>(context, listen: false);
      await myModel.loadOtherNodes();
      // await myModel.loadOtherNodes();

      await getDir("media");
      await getDir("media/images");
      await getDir("media/videos");
      await getDir("pageNode");
    });

  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Home(),
      routes: {
        "/pageEditor": (context) => const PageEditor(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}


