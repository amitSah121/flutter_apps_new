

import 'package:flutter/material.dart';

class NotificationHome extends StatefulWidget{
  const NotificationHome({super.key});

  @override
  State<NotificationHome> createState() => _NotificationHomeState();
}

class _NotificationHomeState extends State<NotificationHome>{

  @override
  Widget build(BuildContext context){
    return const Scaffold(
      body: Text("JHello"),
    );
  }
}