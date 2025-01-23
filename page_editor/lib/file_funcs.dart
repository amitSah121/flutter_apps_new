import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'package:permission_handler/permission_handler.dart';

Future<Directory> getUserDirectory({String dir = ""}) async {
  // Request storage permission
  final permissionStatus = await Permission.storage.status;
  
  if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
    await Permission.storage.request();

    if (permissionStatus.isPermanentlyDenied) {
      await openAppSettings();
    }
  } else {
    Directory? userDir;

    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        userDir = Directory("/storage/emulated/0/PageEditor/$dir");
      } else {
        await Permission.manageExternalStorage.request();
        if (await Permission.manageExternalStorage.isGranted) {
          userDir = Directory("/storage/emulated/0/PageEditor/$dir");
        } else {
          await openAppSettings();
        }
      }
    }

    if (userDir != null && !await userDir.exists()) {
      await userDir.create(recursive: true);
    }

    return userDir ?? Directory("/storage/emulated/0/PageEditor/$dir");
  }

  return Directory("/storage/emulated/0/PageEditor/$dir");
}

Future<String> get localPath async {
  final directory = await getUserDirectory();
  return directory.path;
}

Future<File> getFile(String fileName) async {
  final path = await localPath;
  final file = File('$path/$fileName');

  if (!await file.exists()) {
    await file.create(recursive: true); 
  }
  return file;
}

Future<void> deleteFile(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';

  final file = File(filePath);

  if (await file.exists()) {
    await file.delete();
    // print('File $fileName.csv deleted successfully.');
  } 
}

Future<Directory> getDir(String dirName) async {
  final path = await localPath;
  final dir = Directory('$path/$dirName');

  if (!await dir.exists()) {
    await dir.create(recursive: true); 
  }

  return dir;
}

Future<List<String>> listFilesOnly({dir=""}) async {
  final files = (await getDir(dir))
    .listSync(recursive: true)
    .whereType<File>()
    .map((file) => file.path)
    .toList();
  return files;
} 

Future<File> writeFile(String fileName, String data, {mode = FileMode.write}) async {
  final file = await getFile(fileName);

  var p = await file.writeAsString(data, mode: mode);

  return p;
}


Future<String> readFile(String fileName) async {
  try {
    final file = await getFile(fileName);
    final contents = await file.readAsString();
    return contents;
  } catch (e) {
    // print("Error reading: $e");
    return "";
  }
}

/*
void main() async {
  final people = await readCsvAnim<Person>(
    'people.csv', 
    (row) => Person.fromCsvRow(row),  // Pass the factory function
  );

  print('Loaded people: ${people.map((p) => p.toJson())}');
}

*/

Future<File> writeJson<R extends JsonConvertible>(String fileName, List<R> data) async {
  if (!fileName.contains(".json")) {
    throw Exception("Invalid file name. The file must have a '.json' extension.");
  }

  final file = await getFile(fileName);

  if (data.isEmpty) {
    throw Exception("No data provided");
  }

  final jsonData = data.map((item) => item.toJson()).toList();
  final jsonString = jsonEncode(jsonData);

  var temp = await File('${await localPath}/updatedFilesInfo').readAsString();
  var isAvail = false;
  for(var t1 in temp.split('\n')){
    // print({t1,fileName});
    if(t1 == fileName){
      isAvail = true;
      break;
    }
  }
  if(!isAvail){
    File('${await localPath}/updatedFilesInfo').writeAsString('$temp\n$fileName') ;
  }

  return await file.writeAsString(jsonString);
}

Future<List<R>> readJson<R extends JsonConvertible>(
    String fileName, R Function(Map<String, dynamic>) fromJson) async {
  if (!fileName.contains(".json")) {
    throw Exception("Invalid file name. The file must have a '.json' extension.");
  }

  try {
    final file = await getFile(fileName);
    final contents = await file.readAsString();
    final List<dynamic> jsonData = jsonDecode(contents);

    return jsonData.map((item) => fromJson(item as Map<String, dynamic>)).toList();
  } catch (e) {
    // print("Error reading JSON: $e");
    return [];
  }
}

abstract class JsonConvertible {
  Map<String, dynamic> toJson();
}
