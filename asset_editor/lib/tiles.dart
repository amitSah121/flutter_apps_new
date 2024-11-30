

import 'package:asset_editor/constants.dart';
import 'package:flutter/material.dart';

class TilesHome extends StatelessWidget{
  const TilesHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: appTheme_1,
        title: const Text(
          "Tile Editor",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

}