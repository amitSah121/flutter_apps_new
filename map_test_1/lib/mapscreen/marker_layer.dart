import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

Widget markerClusterLayer(
    List<Position> positions, {
    double width = 120.0,
    double height = 120.0,
    required List<Widget> widgets,
    required Color c
  }) {
  int index = -1;

  // Creating a list of Marker objects
  List<Marker> markers = positions.map((toElement){
      index++;
      return Marker(
        width: width,
        height: height,
        point: LatLng(toElement.latitude, toElement.longitude),
        child: widgets[index]
      );
    }).toList();

  return MarkerClusterLayerWidget(
        options: MarkerClusterLayerOptions(
          maxClusterRadius: 45,
          size: const Size(40, 40),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(50),
          maxZoom: 15,        
          markers: markers,
          builder: (context, markers) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: c),
              child: Center(
                child: Text(
                  markers.length.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        ),
      );
}


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