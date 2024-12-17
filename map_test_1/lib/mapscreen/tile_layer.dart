import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

Widget tileLayer(){
  return TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    tileSize: 256,
    tileProvider:FMTCStore('mapStore').getTileProvider(),
    // subdomains: const ['a', 'b', 'c'], // OSM tile servers
  );
}