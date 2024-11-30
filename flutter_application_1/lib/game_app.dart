

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/go_green.dart';

class GameApp extends StatefulWidget{
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp>{
  late final GoGreen game;

  @override
  void initState(){
    game = GoGreen();
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.amber
      ),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SizedBox(
              width: width,
              height: height,
              child: GameWidget(game: game)),
          ),
        ),
      ),
    );
  }

  

}