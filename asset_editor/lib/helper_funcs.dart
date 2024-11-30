import 'dart:io';
import 'package:asset_editor/constants.dart';
import 'package:asset_editor/helper_classes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> getCsvFile(String fileName) async {
  final path = await localPath;
  final file = File('$path/$fileName.csv');

  if (!await file.exists()) {
    await file.create(recursive: true); 
  }

  return file;
}

Future<void> deleteCsvFile(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName.csv';

  final file = File(filePath);

  if (await file.exists()) {
    await file.delete();
    // print('File $fileName.csv deleted successfully.');
  } 
  // else {
  //   print('File $fileName.csv does not exist.');
  // }
}

Future<List<File>> discoverCsvFiles() async {
  final path = await localPath;
  final directory = Directory(path);

  if (await directory.exists()) {
    var p1 = directory
        .listSync()
        .where((file) => file is File && file.path.endsWith('.csv'))
        .map((file) => File(file.path))
        .toList();
    // print(p1);
    return p1;
  }
  return [];
}

Future<Map<String, List<File>>> classifyFiles() async {
  final files = await discoverCsvFiles();

  List<File> animationFiles = files.where((file) => file.path.contains('animation')).toList();
  List<File> tilesFiles = files.where((file) => file.path.contains('tiles')).toList();

  return {
    'animation': animationFiles,
    'tiles': tilesFiles,
  };
}

Future<File> writeCsvAnim(String fileName, List<SpriteData> data) async {
  final file = await getCsvFile(fileName);

  List<List<dynamic>> rows = [
    ['name', 'id', 'x', 'y', 'w', 'h', 'r', 'frame','fillColor','strokeColor','rtl','rtr','rbl','rbr'], // rtl = round top right ....
    ...data.map((sprite) => sprite.toCsvRow()),
  ];

  String csvData = const ListToCsvConverter().convert(rows);
  // print(csvData);

  var p = await file.writeAsString(csvData);
  return p;
}


Future<File> writeCsvTile(String fileName, List<TileData> data) async {
  final file = await getCsvFile(fileName);

  List<List<dynamic>> rows = [
    ['anim_name', 'x', 'y', 'scale', 'rotation', 'metadata'], // Header row
    ...data.map((tile) => tile.toCsvRow()), // Data rows
  ];

  String csvData = const ListToCsvConverter().convert(rows);

  return file.writeAsString(csvData);
}



Future<List<SpriteData>> readCsvAnim(String fileName) async {
  try {
    final file = await getCsvFile(fileName);

    final contents = await file.readAsString();

    final rows = const CsvToListConverter().convert(contents);
    // print(rows);
    var p = rows.skip(1).map((row) => SpriteData.fromCsvRow(row)).toList();
    // print({p,"jj"});
    return p;
  } catch (e) {
    return []; 
  }
}

Future<List<TileData>> readCsvTile(String fileName) async {
  try {
    final file = await getCsvFile(fileName);

    final contents = await file.readAsString();
    final rows = const CsvToListConverter().convert(contents);

    return rows.skip(1).map((row) => TileData.fromCsvRow(row)).toList();
  } catch (e) {
    return []; 
  }
}



Future<void> initializeFiles() async {
  final classifiedFiles = await classifyFiles();

  for (var file in classifiedFiles['animation']!) {
    files.add(file.path);
  }

  for (var file in classifiedFiles['tiles']!) {
    files.add(file.path);
  }
}

/*

void main() async {
  List<List<dynamic>> animationData = [
    ['anim_name', 'x', 'y', 'scale', 'r', 'metadata'],
    ['walk', 10, 20, 1.5, 0, 'frame1'],
    ['jump', 15, 25, 1.2, 15, 'frame2'],
  ];

  await writeCsv('animation_data', animationData);
  print('Animation data written to animation_data.csv');
}

void main() async {
  List<List<dynamic>> tilesData = await readCsv('tiles_data');
  print('Tiles data: $tilesData');
}



*/