import 'dart:io';

Future<String> get localPath async {
  return './';
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
  final directory = Directory('./');
  final filePath = '${directory.path}/$fileName';

  final file = File(filePath);

  if (await file.exists()) {
    await file.delete();
    // print('File $fileName.csv deleted successfully.');
  } 
  // else {
  //   print('File $fileName.csv does not exist.');
  // }
}

Future<Directory> getDir(String dirName) async {
  final path = await localPath;
  final dir = Directory('$path/$dirName');

  if (!await dir.exists()) {
    await dir.create(recursive: true); 
  }

  return dir;
}

Future<void> deleteDir(String dirName) async {
  final directory = Directory('./');
  final dirPath = '${directory.path}/$dirName';

  final dir = Directory(dirPath);

  if (await dir.exists()) {
    await dir.delete();
    // print('File $fileName.csv deleted successfully.');
  } 
  // else {
  //   print('File $fileName.csv does not exist.');
  // }
}


Future<void> deleteDirRecursive(String dirName) async {
  try {
    // Get the application documents directory
    final directory = Directory('./');
    final dirPath = '${directory.path}/$dirName';

    // Create a Directory object
    final dir = Directory(dirPath);

    // Check if the directory exists
    if (await dir.exists()) {
      // Delete the directory and its contents recursively
      await dir.delete(recursive: true);
      print('Directory $dirName deleted successfully.');
    } else {
      print('Directory $dirName does not exist.');
    }
  } catch (e) {
    print('Failed to delete directory $dirName: $e');
  }
}


Future<List<File>> discoverFiles({String dir = "",String extensions = ""}) async {
  String path = await localPath;
  path = "$path/$dir";
  final directory = Directory(path);

  if (await directory.exists()) {
    // Split extensions into a list and remove empty strings 
    // extensions is ".csv,.txt,.json"
    List<String> validExtensions = extensions.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    var files = directory
        .listSync()
        .where((file) =>
            file is File &&
            (validExtensions.isEmpty || validExtensions.any((ext) => file.path.endsWith(ext))))
        .map((file) => File(file.path))
        .toList();

    return files;
  }
  return [];
}

Future<List<Directory>> discoverDirs({String dir = ""}) async {
  String path = await localPath;
  path = "$path/$dir";
  final directory = Directory(path);

  if (await directory.exists()) {

    var dirs = directory
        .listSync()
        .where((file) =>
            file is Directory)
        .map((file) => Directory(file.path))
        .toList();

    return dirs;
  }
  return [];
}

Future<List<String>> listFilesDirs({String pattern = "*",dir = ""}) async {
  String path = await localPath;
  path = "$path/$dir";
  final directory = Directory(path);

  List<String> result = [];

  if (await directory.exists()) {
    await _listFilesAndDirs(directory, pattern, "", result);
  }

  return result;
}

Future<void> _listFilesAndDirs(  // note the pattern can only contain *,*/*,*/*/*,....
  Directory directory,
  String pattern,
  String indent,
  List<String> result,
) async {
  if(pattern.isEmpty) return;
  final allEntities = directory.listSync();

  for (var entity in allEntities) {
    bool isDirectory = entity is Directory;

    result.add("$indent${entity.path}");
    print("$indent${entity.path}");
    // print(pattern);

    // If the pattern requires recursive search, dive into subdirectories
    if (isDirectory) {
      await _listFilesAndDirs(
        Directory(entity.path),
        pattern.length > 2 ? pattern.substring(2) : "",
        "$indent\t",
        result,
      );
    }
  }
}

Future<File> writeFile(String fileName, String data, {FileMode mode = FileMode.write}) async {
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
    print("Error reading: $e");
    return "";
  }
}


