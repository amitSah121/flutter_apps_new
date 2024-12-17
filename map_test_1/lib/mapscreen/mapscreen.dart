
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:map_test_1/helper_classes/model.dart';
import 'package:map_test_1/helpers_funcs/location_finder.dart';
import 'package:map_test_1/helpers_funcs/misselenious.dart';
import 'package:map_test_1/mapscreen/marker_layer.dart';
import 'package:map_test_1/mapscreen/tile_layer.dart';

class MapScreen extends StatefulWidget {
  MapScreen({super.key});
  late final childSetState;
  final locationIcon = const Icon(Icons.location_on_outlined, color: Colors.green, size: 40,);
  Position? current;
  double currentZoom = 16.0;
  List<PathNode>? pathNodes;
  List<PageNode>? pageNodes;
  List<MediaNode>? mediaNodes;
  bool goMyLoc = true;
  Offset? currentMarker;


  void getLocation(){
    Future.microtask(() async {
      try{
        current = await determinePosition();
      }catch (e){
        // print(e);
      }
      childSetState(() {
        // print({"Something",current});
      });
    });
  }

  @override
  State<MapScreen> createState() => _MapScreenState(); 
}

class _MapScreenState extends State<MapScreen>{
  final MapController _mapController = MapController();


  @override
  void initState(){
    super.initState();
    widget.childSetState = setState;
    
    widget.getLocation();
  }


  @override
  Widget build(BuildContext context) {
    var lat = 51.5, lon = -0.09;
    List<Position> markers = [];
    if(widget.current != null){
      lat = widget.current!.latitude;
      lon = widget.current!.longitude;
      if(!markers.contains(widget.current)){
        markers.add(widget.current!);
      }
      if(widget.goMyLoc){
        _mapController.move(LatLng(widget.current!.latitude, widget.current!.longitude), widget.currentZoom);
        setState(() {
          
        });
      }
      // print({lat,lon});
    }else{
      markers.add(Position(longitude: lon, latitude: lat, timestamp: DateTime(2024), accuracy: 0.01, altitude: 100, altitudeAccuracy: 0.1, heading: 1, headingAccuracy: 1, speed: 1, speedAccuracy: 1));
    }

    List<Position> pathMarker = [];
    List<Position> mediaMarker = [];
    List<Position> pageMarker = [];

    List<Widget> pathIcons = [];
    List<Widget> pageIcons = [];
    List<Widget> mediaIcons = [];

    if(widget.pathNodes != null && widget.pathNodes!.isNotEmpty){
      PathNode? temp;
      for(var p in widget.pathNodes!){
        if(temp == null){
          temp = p;
        }else{
          var temp1 = fillMediaNodes(p, temp,);
          if(temp1 != null){
            mediaMarker.add(temp1);
            mediaIcons.add(MediaNode.icon);
          }

          temp1 = fillPageNode(p, temp,);
          if(temp1 != null){
            pageMarker.add(temp1);
            pageIcons.add(PageNode.icon);
          }
        }
        pathIcons.add(PathNode.icon);
        pathMarker.add(Position(longitude: p.longitude, latitude: p.latitude, timestamp: p.timestamp, accuracy: p.accuracy, altitude: p.altitude, altitudeAccuracy: p.altitudeAccuracy, heading: p.heading, headingAccuracy: p.headingAccuracy, speed: p.speed, speedAccuracy: p.speedAccuracy));
      }
      var temp1 = fillMediaNodes(widget.pathNodes!.first, temp!);
      if(temp1 != null){
        mediaMarker.add(temp1);
      }
      if(!widget.goMyLoc){
        Future.microtask(()async{
          _mapController.move(LatLng(widget.pathNodes![0].latitude, widget.pathNodes![0].longitude), widget.currentZoom);
        });
      }
    }

    List<LatLng> polylines = [];
    if(widget.pageNodes != null){
      polylines = createPolygonFromPathNodes(widget.pathNodes!);
    }
    
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(lat, lon),
        initialZoom: 1.0,
        onTap: (tapPosition, point) {
        }
      ),
      children: [
        tileLayer(),
        polylineLayer(polylines),
        markerLayer(pathMarker,widget: pathIcons),
        markerLayer(pageMarker,widget: pageIcons),
        markerLayer(mediaMarker,widget: mediaIcons),
        markerLayer(markers,widget: markers.map((e)=> widget.locationIcon).toList()),
      ]
    );
  }

  

  Position? fillMediaNodes(PathNode p, PathNode temp) {
    Position? mediaMarker;
    if(widget.mediaNodes != null && widget.mediaNodes!.isNotEmpty){
      for(var q in widget.mediaNodes!){
        if((q.pathNumber_1 == p.pathNumber && q.pathNumber_2 == temp.pathNumber)){
          var longitude = (temp.longitude - p.longitude)*q.t + p.longitude;
          var latitude = (temp.latitude - p.latitude)*q.t + p.latitude;
          mediaMarker = Position(longitude: longitude, latitude: latitude, timestamp: p.timestamp, accuracy: p.accuracy, altitude: p.altitude, altitudeAccuracy: p.altitudeAccuracy, heading: p.heading, headingAccuracy: p.headingAccuracy, speed: p.speed, speedAccuracy: p.speedAccuracy);
        }else if((q.pathNumber_1 == temp.pathNumber && q.pathNumber_2 == p.pathNumber)){
          var longitude = (p.longitude - temp.longitude)*q.t + temp.longitude;
          var latitude = (p.latitude - temp.latitude)*q.t + temp.latitude;
          mediaMarker = Position(longitude: longitude, latitude: latitude, timestamp: p.timestamp, accuracy: p.accuracy, altitude: p.altitude, altitudeAccuracy: p.altitudeAccuracy, heading: p.heading, headingAccuracy: p.headingAccuracy, speed: p.speed, speedAccuracy: p.speedAccuracy);
        }
      }
    }
  
    return mediaMarker;
  }

  Position? fillPageNode(PathNode p, PathNode temp){
    Position? pageMarker;
    if(widget.pageNodes != null && widget.pageNodes!.isNotEmpty){
      for(var q in widget.pageNodes!){
        if((q.pathNumber_1 == p.pathNumber && q.pathNumber_2 == temp.pathNumber)){
          var longitude = (temp.longitude - p.longitude)*q.t + p.longitude;
          var latitude = (temp.latitude - p.latitude)*q.t + p.latitude;
          pageMarker = Position(longitude: longitude, latitude: latitude, timestamp: p.timestamp, accuracy: p.accuracy, altitude: p.altitude, altitudeAccuracy: p.altitudeAccuracy, heading: p.heading, headingAccuracy: p.headingAccuracy, speed: p.speed, speedAccuracy: p.speedAccuracy);
        }else if((q.pathNumber_1 == temp.pathNumber && q.pathNumber_2 == p.pathNumber)){
          var longitude = (p.longitude - temp.longitude)*q.t + temp.longitude;
          var latitude = (p.latitude - temp.latitude)*q.t + temp.latitude;
          pageMarker = Position(longitude: longitude, latitude: latitude, timestamp: p.timestamp, accuracy: p.accuracy, altitude: p.altitude, altitudeAccuracy: p.altitudeAccuracy, heading: p.heading, headingAccuracy: p.headingAccuracy, speed: p.speed, speedAccuracy: p.speedAccuracy);
        }
      }
    }
    return pageMarker;
  }
}
