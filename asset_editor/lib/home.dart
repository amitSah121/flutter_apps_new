import 'dart:io';

import 'package:asset_editor/helper_funcs.dart';
import 'package:flutter/material.dart';
import 'package:asset_editor/constants.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: appTheme_1,
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
              // print("Hello");
            },
            icon: const Icon(Icons.menu)),
        title: const Text(
          appName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: customDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.animation),
                title: const Text("Animation"),
                onTap: () {
                  Navigator.pushNamed(context, "/animation");
                },
              ),
              ListTile(
                leading: const Icon(Icons.rectangle),
                title: const Text("Tiles"),
                onTap: () {
                  Navigator.pushNamed(context, "/tiles");
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Drawer customDrawer() {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
              leading: const Icon(Icons.settings),
              title: TextButton(
                onPressed: () {
                  // Future.microtask(() async {
                  //   print((await getCsvFile("temp")).path);
                  // });

                  // Future<void> deleteAllFiles() async {
                  //   // Get the application documents directory
                  //   final directory = await getApplicationDocumentsDirectory();
                  //   final dir = Directory(directory.path);

                  //   // List all files in the directory
                  //   final files = dir
                  //       .listSync(); // Get all entities in the directory (files and folders)

                  //   for (var fileOrDir in files) {
                  //     if (fileOrDir is File) {
                  //       try {
                  //         await fileOrDir.delete(); // Delete the file
                  //         // print('Deleted: ${fileOrDir.path}');
                  //       } catch (e) {
                  //         // print('Failed to delete ${fileOrDir.path}: $e');
                  //       }
                  //     }
                  //   }

                  //   print('All files deleted.');
                  // }

                  Future.microtask(()async{
                    // deleteAllFiles();
                    print(await readCsvAnim("animation_temp"));
                  });

                  setState(() {});
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Settings'),
                ),
              )),
        ],
      ),
    );
  }
}
