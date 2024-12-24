import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

import 'dart:convert';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();
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
  final directory = await getApplicationDocumentsDirectory();
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
    final directory = await getApplicationDocumentsDirectory();
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
    print("Error reading: $e");
    return "";
  }
}



Future<File> writeCsv<R extends CsvConvertible>(String fileName, List<R> data) async {
  if(!fileName.contains(".csv")){
    throw Exception("Invalid file name. The file must have a '.csv' extension.");
  }

  final file = await getFile(fileName);
  List<List<dynamic>> rows = [];

  // Assuming `R` has a `toJson` or `toMap` method to convert an object to a map
  if (data.isNotEmpty) {
    // commented this out because we don't necessarily need these
    // final headers = (data.first as dynamic).toJson().keys.toList();
    // rows.add(headers);

    for (var item in data) {
      final values = (item as dynamic).toJson().values.toList();
      rows.add(values);
    }
  }else{
    throw Exception("No data provided");
  }

  String csvData = const ListToCsvConverter().convert(rows);

  var p = await file.writeAsString(csvData);
  return p;
}


Future<List<R>> readCsv<R extends CsvConvertible>(
    String fileName, R Function(List<dynamic>) fromCsvRow) async {
  if (!fileName.contains(".csv")) {
    throw Exception("Invalid file name. The file must have a '.csv' extension.");
  }

  try {
    final file = await getFile(fileName);
    final contents = await file.readAsString();
    final rows = const CsvToListConverter().convert(contents);

    // Skip header and convert rows to list of R using the passed factory function
    var result = rows.map((row) => fromCsvRow(row)).toList();
    return result;
  } catch (e) {
    print("Error reading CSV: $e");
    return [];
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

Future<Map<String, List<File>>> classifyFiles({String prefixes = ""}) async {
  final files = await discoverFiles(extensions: '.csv');

  List<String> prefixList = prefixes.split(',').map((e) => e.trim()).toList();

  Map<String, List<File>> classifiedFiles = {};

  for (var prefix in prefixList) {
    List<File> matchingFiles = files.where((file) => file.path.contains(prefix)).toList();
    classifiedFiles[prefix] = matchingFiles;
  }

  return classifiedFiles;
}



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
    print("Error reading JSON: $e");
    return [];
  }
}

Future<File> writeYaml<R extends JsonConvertible>(String fileName, List<R> data) async {
  if (!fileName.contains(".yaml")) {
    throw Exception("Invalid file name. The file must have a '.yaml' extension.");
  }

  final file = await getFile(fileName);

  if (data.isEmpty) {
    throw Exception("No data provided");
  }

  final yamlWriter = YamlWriter();
  final yamlData = data.map((item) => item.toJson()).toList();
  final yamlString = yamlWriter.write(yamlData);

  return await file.writeAsString(yamlString);
}

Future<List<R>> readYaml<R extends JsonConvertible>(
    String fileName, R Function(Map<String, dynamic>) fromYaml) async {
  if (!fileName.contains(".yaml")) {
    throw Exception("Invalid file name. The file must have a '.yaml' extension.");
  }

  try {
    final file = await getFile(fileName);
    final contents = await file.readAsString();
    final yamlData = loadYaml(contents);

    if (yamlData is List) {
      return yamlData
          .map((item) => fromYaml(Map<String, dynamic>.from(item)))
          .toList();
    } else {
      throw Exception("Invalid YAML format. Expected a list.");
    }
  } catch (e) {
    print("Error reading YAML: $e");
    return [];
  }
}

abstract class JsonConvertible {
  Map<String, dynamic> toJson();
}

abstract class CsvConvertible {
  factory CsvConvertible.fromCsvRow(List<dynamic> row) =>
      throw UnimplementedError();
  List<dynamic> toCsvRow();
}




/*
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

// Assuming that the model file exists and contains the CsvConvertible class and Person class
class CsvConvertible {
  Map<String, dynamic> toJson();
  factory CsvConvertible.fromCsvRow(List<dynamic> row);
}

class Person implements CsvConvertible {
  final String name;
  final int age;

  Person(this.name, this.age);

  // Factory constructor to create a Person from a CSV row
  factory Person.fromCsvRow(List<dynamic> row) {
    return Person(row[0] as String, row[1] as int);
  }

  // Converts a Person object to a map for CSV writing
  @override
  Map<String, dynamic> toJson() {
    return {'name': name, 'age': age};
  }
}

// 1. Write a CSV with list of Persons
Future<void> writeExampleCsv() async {
  List<Person> people = [
    Person('Alice', 30),
    Person('Bob', 25),
    Person('Charlie', 35),
  ];

  await writeCsv<Person>('people.csv', people);
  print('CSV file written');
}

// 2. Read the CSV back into a list of Persons
Future<void> readExampleCsv() async {
  List<Person> people = await readCsv<Person>(
    'people.csv',
    (row) => Person.fromCsvRow(row),
  );
  people.forEach((person) {
    print('Person: ${person.name}, Age: ${person.age}');
  });
}

// 3. Classify files by prefixes
Future<void> classifyCsvFiles() async {
  Map<String, List<File>> classifiedFiles = await classifyFiles(prefixes: 'animation,tiles');
  classifiedFiles.forEach((prefix, files) {
    print('Files with prefix "$prefix":');
    files.forEach((file) {
      print(file.path);
    });
  });
}

// 4. Example of file deletion
Future<void> deleteExampleFile() async {
  await deleteFile('people.csv');
  print('File deleted');
}

// 5. Discover all CSV files
Future<void> discoverCsvFiles() async {
  List<File> files = await discoverFiles(extensions: '.csv');
  print('Discovered CSV files:');
  files.forEach((file) {
    print(file.path);
  });
}

void main() async {
  // Use the functions

  // Write CSV file
  await writeExampleCsv();

  // Discover CSV files
  await discoverCsvFiles();

  // Read the CSV file
  await readExampleCsv();

  // Classify CSV files based on prefixes
  await classifyCsvFiles();

  // Delete the example CSV file
  await deleteExampleFile();
}

*/