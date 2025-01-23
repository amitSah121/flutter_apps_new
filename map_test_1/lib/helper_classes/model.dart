import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';

class PathNode implements JsonConvertible, CsvConvertible {
  double longitude;
  double latitude;
  double accuracy;
  double altitude;
  double altitudeAccuracy;
  double heading;
  double headingAccuracy;
  double speed;
  double speedAccuracy;
  DateTime timestamp;
  String fillColor; // to color circles
  int pathNumber;
  String metadata;
  static Widget icon = const Icon(Icons.circle,size: 8,);
  static Widget icons = const Icon(Icons.circle, size: 4,);

  PathNode({
    required this.longitude,
    required this.latitude,
    required this.accuracy,
    required this.altitude,
    required this.altitudeAccuracy,
    required this.heading,
    required this.headingAccuracy,
    required this.speed,
    required this.speedAccuracy,
    required this.timestamp,
    required this.fillColor,
    required this.pathNumber,
    this.metadata = "",
  });

  factory PathNode.fromPosition(Position pos, pathNumber) {
    return PathNode(
        longitude: pos.longitude,
        latitude: pos.latitude,
        accuracy: pos.accuracy,
        altitude: pos.altitude,
        altitudeAccuracy: pos.altitudeAccuracy,
        heading: pos.heading,
        headingAccuracy: pos.headingAccuracy,
        speed: pos.speed,
        speedAccuracy: pos.speedAccuracy,
        timestamp: pos.timestamp,
        fillColor: Colors.white.value.toString(),
        pathNumber: pathNumber);
  }

  String getType(){
    return "path";
  }

  factory PathNode.fromCsvRow(List<dynamic> row) {
    return PathNode(
        longitude: row[0] as double,
        latitude: row[1] as double,
        accuracy: row[2] as double,
        altitude: row[3] as double,
        altitudeAccuracy: row[4] as double,
        heading: row[5] as double,
        headingAccuracy: row[6] as double,
        speed: row[7] as double,
        speedAccuracy: row[8] as double,
        timestamp: DateTime.parse(row[9] as String),
        fillColor: row[10].toString().padLeft(8, '0'),
        pathNumber: row[11] as int,
        metadata: row[12] as String);
  }

  List<dynamic> toCsvRow() {
    return [
      longitude,
      latitude,
      altitude,
      timestamp.toIso8601String(),
      fillColor,
      pathNumber,
      metadata
    ];
  }

  factory PathNode.fromJson(Map<String, dynamic> json) {
    return PathNode(
      longitude: json['longitude'],
      latitude: json['latitude'],
      accuracy: json['accuracy'],
      altitude: json['altitude'],
      altitudeAccuracy: json['altitudeAccuracy'],
      heading: json['heading'],
      headingAccuracy: json['headingAccuracy'],
      speed: json['speed'],
      speedAccuracy: json['speedAccuracy'],
      timestamp: DateTime.parse(json['timestamp']),
      fillColor: json['fillColor'],
      pathNumber: json['pathNumber'],
      metadata: json['metadata'] ?? "",
    );
  }

  

  @override
  Map<String, dynamic> toJson() {
    return {
      'longitude': longitude,
      'latitude': latitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'altitudeAccuracy': altitudeAccuracy,
      'heading': heading,
      'headingAccuracy': headingAccuracy,
      'speed': speed,
      'speedAccuracy': speedAccuracy,
      'timestamp': timestamp.toIso8601String(),
      'fillColor': fillColor,
      'pathNumber': pathNumber,
      'metadata': metadata,
    };
  }
}

class MediaNode implements JsonConvertible, CsvConvertible {
  int pathNumber_1,
      pathNumber_2; // number assigned to path nodes that forms an edge
  double t; // t belongs to [0,1]
  String medialLink;
  bool isMediaHttp; // if media is a web image link
  String text;
  double mediaHeight;
  int mediaNumber; // used to denote the mediaNode present in a journey
  String metadata;
  static Widget icon = const Icon(Icons.photo);
  static Widget icons = const Icon(Icons.photo_album);

  MediaNode({
    required this.pathNumber_1,
    required this.pathNumber_2,
    required this.t,
    this.medialLink = "",
    this.isMediaHttp = false,
    this.text = "",
    required this.mediaHeight,
    required this.mediaNumber,
    this.metadata = "",
  });

  String getType(){
    return "media";
  }

  factory MediaNode.fromCsvRow(List<dynamic> row) {
    return MediaNode(
        pathNumber_1: row[0] as int,
        pathNumber_2: row[1] as int,
        t: row[2] as double,
        medialLink: row[3] as String,
        isMediaHttp: row[4] as bool,
        text: row[5] as String,
        mediaHeight: row[6] as double,
        mediaNumber: row[7] as int,
        metadata: row[8] as String);
  }

  List<dynamic> toCsvRow() {
    return [
      pathNumber_1,
      pathNumber_2,
      t,
      medialLink,
      isMediaHttp,
      text,
      mediaHeight,
      mediaNumber,
      metadata
    ];
  }

  factory MediaNode.fromJson(Map<String, dynamic> json) {
    return MediaNode(
      pathNumber_1: json['pathNumber_1'],
      pathNumber_2: json['pathNumber_2'],
      t: json['t'],
      medialLink: json['medialLink'],
      isMediaHttp: json['isMediaHttp'],
      text: json['text'],
      mediaHeight: json["mediaHeight"],
      mediaNumber: json['mediaNumber'],
      metadata: json['metadata'] ??
          "", // includes arguments as key value pair separated by ";", so fileName=$time;title=Untitled;.....
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'pathNumber_1': pathNumber_1,
      'pathNumber_2': pathNumber_2,
      't': t,
      'medialLink': medialLink,
      'isMediaHttp': isMediaHttp,
      'text': text,
      'mediaHeight': mediaHeight,
      'mediaNumber': mediaNumber,
      'metadata': metadata,
    };
  }
}

class RowMap implements JsonConvertible {
  Map<int, String> rows;
  // note for media node format is
  // customUrl/media/images/....[imageformat] __5050__media__5050__ 300
  // https://....[imageformat] __5050__media__5050__ 300
  // customUrl/media/images/....[videoFormat] __5050__media__5050__ 300
  // https://....[videoformat] __5050__media__5050__ 300

  RowMap({required this.rows});

  factory RowMap.fromJson(Map<String, dynamic> json) {
    return RowMap(
      rows: json.map((key, value) => MapEntry(int.parse(key), value as String)),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return rows.map((key, value) => MapEntry(key.toString(), value));
  }
}

class PageNode implements JsonConvertible {
  RowMap rows; // row number and text input
  int pathNumber_1, pathNumber_2;
  double t;
  int pageNumber;
  String
      metadata; // includes arguments as key value pair separated by ";", so fileName=$time;title=Untitled;backgroundColor=Colors.White.value.toString();.....
  static Widget icon = const Icon(Icons.bookmark_sharp);
  static Widget icons = const Icon(Icons.bookmarks_sharp);

  PageNode({
    required this.rows,
    required this.pathNumber_1,
    required this.pathNumber_2,
    required this.t,
    required this.pageNumber,
    this.metadata = "",
  });

  factory PageNode.fromJson(Map<String, dynamic> json) {
    return PageNode(
      rows: RowMap.fromJson(json['rows']),
      pathNumber_1: json['pathNumber_1'],
      pathNumber_2: json['pathNumber_2'],
      t: json['t'],
      pageNumber: json['pageNumber'],
      metadata: json['metadata'] ?? "",
    );
  }

  String getType(){
    return "page";
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'rows': rows.toJson(),
      'pathNumber_1': pathNumber_1,
      'pathNumber_2': pathNumber_2,
      't': t,
      'pageNumber': pageNumber,
      'metadata': metadata,
    };
  }
}

class Journey {
  // note: file name must be saved with a unique number
  List<PageNode> pageNodes = []; // paths of pathNode
  List<MediaNode> mediaNodes = []; // paths of mediaNode
  List<PathNode> pathNodes = []; // path of path node
  String? name; // default foldername=$time
  String metadata = "title=untitled;autopathDone=false"; // title=untitled; if authpath=none then goes to tracer otherwise manualeditor

  Journey(String folderName) {
    // folder name of journeys inside journey folder
    name = folderName;
  }

  String getType(){
    return "journey";
  }

  Future<bool> fillVariables() async {
    var files = await discoverFiles(
        dir: "$journeyPath/$name"); // journey/journey name1/
    // print({files,"$journeyPath/$name"});
    for (var file in files) {
      if (file.path.contains("pathNode")) {
        String fileName = file.path.split('/').last;
        var json = await readJson(
            "$journeyPath/$name/$fileName", (row) => PathNode.fromJson(row));
        pathNodes = json;
      } else if (file.path.contains("pageNode")) {
        String fileName = file.path.split('/').last;
        var json = await readJson(
            "$journeyPath/$name/$fileName", (row) => PageNode.fromJson(row));
        pageNodes = json;
      } else if (file.path.contains("mediaNode")) {
        String fileName = file.path.split('/').last;
        var json = await readJson(
            "$journeyPath/$name/$fileName", (row) => MediaNode.fromJson(row));
        mediaNodes = json;
      }
      // print("$journeyPath/$name");
    }
    // writeFile("$journeyPath/$name/metadata", metadata);
    metadata = await readFile("$journeyPath/$name/metadata");
    return true;
  }
}
