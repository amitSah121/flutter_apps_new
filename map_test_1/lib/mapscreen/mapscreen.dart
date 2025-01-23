
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
  MapScreen({super.key,});
  Function(TapPosition, LatLng)? onTap;
  Function(PointerDownEvent, LatLng)? onPointerDown;
  Function(PointerUpEvent, LatLng)? onPointerUp;
  Function(PointerHoverEvent, LatLng)? onPointerHover;
  bool shouldLessInteract = false;
  late var childSetState;
  final locationIcon = const Icon(Icons.location_on_outlined, color: Colors.green, size: 40,);
  Position? current;
  double currentZoom = 16.0;
  LatLng currentCamPos = const LatLng(76,76);
  List<PathNode>? pathNodes;
  List<PageNode>? pageNodes;
  List<MediaNode>? mediaNodes;
  List<Widget> extralayers = [];
  bool goMyLoc = true;
  Offset? currentMarker;  
  final MapController mapController = MapController();
  bool donUseMyGeoLoc = false;
  bool dummy = false;
  bool toShowPathMarker = true;
  Icon? pathMarkerCustom;
  Icon? pageMarkerCustom;
  Icon? mediaMarkerCustom;
  
  

  // MapCamera? camera;


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

  Point<double> getPoint(){
    return const Point(1,1);
  }

  Point<double> getXYPoint(x,y){
    return Point(x,y);
  }

  MapCamera getCamera(){
    return mapController.camera;
  }

  @override
  State<MapScreen> createState() => _MapScreenState(); 
}

class _MapScreenState extends State<MapScreen>{


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
      // widget.currentCamPos = LatLng(lat, lon);
      if(!markers.contains(widget.current)){
        markers.add(widget.current!);
      }
      if(widget.goMyLoc){
        try{
          widget.mapController.move(LatLng(widget.current!.latitude, widget.current!.longitude), widget.currentZoom);
          setState(() {
            
          });
        }catch (e){}
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
          if(temp1.isNotEmpty){
            for(var pc in temp1){
              mediaMarker.add(pc);
              mediaIcons.add(widget.mediaMarkerCustom ?? MediaNode.icon);
            }
          }

          var temp2 = fillPageNode(p, temp,);
          if(temp2.isNotEmpty){
            for(var tc in temp2){
              pageMarker.add(tc);
              pageIcons.add(widget.pageMarkerCustom ?? PageNode.icon);
            }
          }
          temp = p;
        }
        // print(widget.pathMarkerCustom);
        pathIcons.add(widget.pathMarkerCustom ?? PathNode.icon);
        pathMarker.add(Position(longitude: p.longitude, latitude: p.latitude, timestamp: p.timestamp, accuracy: p.accuracy, altitude: p.altitude, altitudeAccuracy: p.altitudeAccuracy, heading: p.heading, headingAccuracy: p.headingAccuracy, speed: p.speed, speedAccuracy: p.speedAccuracy));
      }
      // var temp1 = fillMediaNodes(widget.pathNodes!.first, temp!);
      // if(temp1.isNotEmpty){
      //   for(var pc in temp1){
      //       mediaMarker.add(pc);
      //       mediaIcons.add(MediaNode.icon);
      //     }
      // }
      if(!widget.goMyLoc){
        Future.microtask(()async{
          if(widget.donUseMyGeoLoc) return;
          widget.mapController.move(LatLng(widget.pathNodes![0].latitude, widget.pathNodes![0].longitude), widget.currentZoom);
          // CameraFit
        });
      }
    }

    List<LatLng> polylines = [];
    if(widget.pageNodes != null){
      polylines = createPolygonFromPathNodes(widget.pathNodes!);
    }

    var p = [
        tileLayer(),
        polylineLayer(polylines),
        markerLayer(pathMarker,widget: pathIcons),
        markerLayer(pageMarker,widget: pageIcons),
        markerLayer(mediaMarker,widget: mediaIcons),
        markerLayer(markers,widget: markers.map((e)=> widget.locationIcon).toList()),
      ];

    // var p = [
    //     tileLayer(),
    //     polylineLayer(polylines),
    //     markerLayer(pathMarker,widget: pathIcons),
    //     markerClusterLayer(pageMarker,widgets: pageIcons, c: Colors.green),
    //     markerClusterLayer(mediaMarker,widgets: mediaIcons, c: Colors.blue),
    //     markerLayer(markers,widget: markers.map((e)=> widget.locationIcon).toList()),
    //   ];
    p.addAll(widget.extralayers.map((e)=>e));
    // widget.camera = widget.mapController.camera;
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        initialCenter: widget.currentCamPos,
        initialZoom: widget.currentZoom,
        onTap: (tapPosition, point) {
          if(widget.onTap != null){
            widget.onTap!(tapPosition,point);
          }
        },
        onPointerDown: (eventType,latlang){
          if(widget.onPointerDown != null){
            widget.onPointerDown!(eventType,latlang);
          }
        },
        onPointerUp: (eventType,latlang){
          if(widget.onPointerUp != null){
            widget.onPointerUp!(eventType,latlang);
          }
        },
        onPointerHover: (eventType , latlng){
          if(widget.onPointerHover != null){
            widget.onPointerHover!(eventType, latlng);
          }
        },
        onPositionChanged: (cam,b){
          widget.currentZoom = cam.zoom;
          // widget.currentCamPos = ;
        },
        interactionOptions: widget.shouldLessInteract ? const InteractionOptions(flags: InteractiveFlag.pinchMove | InteractiveFlag.pinchZoom) : const InteractionOptions()
      ),
      children: p
    );
  }

  

  List<Position> fillMediaNodes(PathNode p, PathNode temp) {
    List<Position> mediaMarker = [];
    if(widget.mediaNodes != null && widget.mediaNodes!.isNotEmpty){
      for(var q in widget.mediaNodes!){
        if((q.pathNumber_1 == p.pathNumber && q.pathNumber_2 == temp.pathNumber)){
          var longitude = (temp.longitude - p.longitude)*q.t + p.longitude;
          var latitude = (temp.latitude - p.latitude)*q.t + p.latitude;
          mediaMarker.add(Position(longitude: longitude, latitude: latitude, timestamp: p.timestamp, accuracy: p.accuracy, altitude: p.altitude, altitudeAccuracy: p.altitudeAccuracy, heading: p.heading, headingAccuracy: p.headingAccuracy, speed: p.speed, speedAccuracy: p.speedAccuracy));
        }else if((q.pathNumber_1 == temp.pathNumber && q.pathNumber_2 == p.pathNumber)){
          var longitude = (p.longitude - temp.longitude)*q.t + temp.longitude;
          var latitude = (p.latitude - temp.latitude)*q.t + temp.latitude;
          mediaMarker.add(Position(longitude: longitude, latitude: latitude, timestamp: p.timestamp, accuracy: p.accuracy, altitude: p.altitude, altitudeAccuracy: p.altitudeAccuracy, heading: p.heading, headingAccuracy: p.headingAccuracy, speed: p.speed, speedAccuracy: p.speedAccuracy));
        }
      }
    }
  
    return mediaMarker;
  }

  List<Position> fillPageNode(PathNode p, PathNode temp){
    List<Position> pageMarkers = [];
    if(widget.pageNodes != null && widget.pageNodes!.isNotEmpty){
      // print({p.pathNumber,temp.pathNumber});
      for(var q in widget.pageNodes!){
        if((q.pathNumber_1 == p.pathNumber && q.pathNumber_2 == temp.pathNumber)){
          var longitude = (temp.longitude - p.longitude)*q.t + p.longitude;
          var latitude = (temp.latitude - p.latitude)*q.t + p.latitude;
          pageMarkers.add(Position(longitude: longitude, latitude: latitude, timestamp: p.timestamp, accuracy: p.accuracy, altitude: p.altitude, altitudeAccuracy: p.altitudeAccuracy, heading: p.heading, headingAccuracy: p.headingAccuracy, speed: p.speed, speedAccuracy: p.speedAccuracy));
          
        }else if((q.pathNumber_1 == temp.pathNumber && q.pathNumber_2 == p.pathNumber)){
          var longitude = (p.longitude - temp.longitude)*q.t + temp.longitude;
          var latitude = (p.latitude - temp.latitude)*q.t + temp.latitude;
          pageMarkers.add(Position(longitude: longitude, latitude: latitude, timestamp: p.timestamp, accuracy: p.accuracy, altitude: p.altitude, altitudeAccuracy: p.altitudeAccuracy, heading: p.heading, headingAccuracy: p.headingAccuracy, speed: p.speed, speedAccuracy: p.speedAccuracy));
          
        }
      }
    }
    return pageMarkers;
  }
}
