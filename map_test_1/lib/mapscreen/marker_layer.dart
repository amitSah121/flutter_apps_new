import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

Widget markerLayer(List<Position> positions,{width = 120.0, height = 120.0, required List<Widget> widget}){
  int index = -1;
  return MarkerLayer(
    markers: positions.map((toElement){
      index++;
      return Marker(
        width: width,
        height: height,
        point: LatLng(toElement.latitude, toElement.longitude),
        child: widget[index]
      );
    }).toList()
  );
}

PolylineLayer<Object> polylineLayer(List<LatLng> polylines) {
  return PolylineLayer(
      polylines: [
        Polyline(
          points: polylines,
          strokeWidth: 4.0,
          color: Colors.blue,
        ),
      ],
    );
}