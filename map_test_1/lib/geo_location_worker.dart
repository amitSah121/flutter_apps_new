

import 'dart:async';
import 'dart:isolate';
import 'package:flutter_map/flutter_map.dart';
import 'package:map_test_1/helpers_funcs/location_finder.dart';
import 'package:map_test_1/main_worker.dart';
import 'package:map_test_1/mapscreen/mapscreen.dart';

class GeoLocationWorker extends Worker{
  late Timer timer;

  GeoLocationWorker(int timeInMiliSec, callback){
    Timer(const Duration(seconds: 3),(){
      timer = Timer.periodic(Duration(milliseconds: timeInMiliSec), callback);
    });
  }

  @override
  void handleResponsesFromIsolate(dynamic message) {
    if (message is SendPort) {
      sendPort = message;
      isolateReady.complete();
    } else{
       if (message is Map<String, dynamic>) {
        print(message);
       }

    }
  }
  

  void dispose(){
    timer.cancel();
  }
}


    // gW = GeoLocationWorker(100, (t) async {
    //   map.goMyLoc = false;
    //   map.donUseMyGeoLoc = true;
    //   // MapCamera m = map.getCamera();
    //   map.current = await determinePositionWithoutCallingPermission();
    //   map.childSetState((){});
    // });