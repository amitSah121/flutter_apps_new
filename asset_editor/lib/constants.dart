

import 'package:flutter/material.dart' show Color, Colors;
import 'package:flutter/services.dart';

double width = 0;
double height = 0;

const appName = 'Assets';
const appTheme_1 = Color.fromARGB(255, 62, 238, 203);

const files = [];

late Map<String,List<List<Color>>> colorPallettes = {};

Future<void> palletteLoadCsv() async {
  try {
    final csvData = await rootBundle.loadString('assets/csv/color_pallette.csv');

    final rows = csvData.split('\n');
    String name = "untitled";
    for (var row in rows) {
      List<Color> colors = [];
      final columns = row.split(',');
      for (var hex in columns) {
        if(hex.startsWith("name")){
          name = hex.trim();
          if(!colorPallettes.keys.contains(name)){
            colorPallettes.addAll({name: []});
          }
        }else if (hex.trim().isNotEmpty) {
          // print(hex);
          final color = hexToColor(hex.trim());
          colors.add(color);
        }
      }
      colorPallettes[name]!.add(colors);
    }

  } catch (e) {}
}

/// Convert a hexadecimal string (e.g., "af343322") to a Flutter Color
Color hexToColor(String hex) {
  // Ensure the string is 8 characters
  if (hex.length != 8){
    hex += "FF";
  }

  final r = int.parse(hex.substring(0, 2), radix: 16);
  final g = int.parse(hex.substring(2, 4), radix: 16);
  final b = int.parse(hex.substring(4, 6), radix: 16);
  final a = int.parse(hex.substring(6, 8), radix: 16);

  return Color.fromARGB(a, r, g, b);
}

String colorToHex(Color color) {
  return '${color.red.toRadixString(16).padLeft(2, '0')}'
         '${color.green.toRadixString(16).padLeft(2, '0')}'
         '${color.blue.toRadixString(16).padLeft(2, '0')}'
         '${color.alpha.toRadixString(16).padLeft(2, '0')}';
}
