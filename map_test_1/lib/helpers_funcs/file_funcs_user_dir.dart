import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<Directory> getUserDirectory({String dir = ""}) async {
  // Request storage permission
  final permissionStatus = await Permission.storage.status;
  
  // For Android 11 and above, check for MANAGE_EXTERNAL_STORAGE permission
  if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
    // Ask for permission
    await Permission.storage.request();

    // Open app settings if permission is permanently denied
    if (permissionStatus.isPermanentlyDenied) {
      await openAppSettings();
    }
  } else {
    // Handle Scoped Storage for Android 10+ and below
    Directory? userDir;

    if (Platform.isAndroid) {
      // For Android 11 and above (Scoped Storage)
      if (await Permission.manageExternalStorage.isGranted) {
        userDir = Directory("/storage/emulated/0/JourneyApp/$dir");
      } else {
        // Request permission for MANAGE_EXTERNAL_STORAGE
        await Permission.manageExternalStorage.request();
        if (await Permission.manageExternalStorage.isGranted) {
          userDir = Directory("/storage/emulated/0/JourneyApp/$dir");
        } else {
          await openAppSettings();
        }
      }
    }

    // If the directory does not exist, create it
    if (userDir != null && !await userDir.exists()) {
      await userDir.create(recursive: true);
    }

    return userDir ?? Directory("/storage/emulated/0/JourneyApp/$dir");
  }

  return Directory("/storage/emulated/0/JourneyApp/$dir");
}


/// Function to write a file in the user's directory
Future<File> writeUserFile(String fileName, String content,{String dir = ""}) async {
  // Get the user directory
  Directory userDir = await getUserDirectory(dir: dir);

  // Ensure the directory exists
  if (!await userDir.exists()) {
    await userDir.create(recursive: true);
  }

  // Define the file path
  File file = File('${userDir.path}/$fileName');

  // Write content to the file
  return await file.writeAsString(content);
}

/// Function to read a file from the user's directory
Future<String> readUserFile(String fileName,{String dir = ""}) async {
  // Get the user directory
  Directory userDir = await getUserDirectory(dir: dir);

  // Define the file path
  File file = File('${userDir.path}/$fileName');

  // Check if the file exists
  if (await file.exists()) {
    // Read the content of the file
    return await file.readAsString();
  } else {
    throw Exception('File does not exist');
  }
}

/// Function to check if a file exists in the user's directory
Future<bool> userFileExists(String fileName,{String dir = ""}) async {
  // Get the user directory
  Directory userDir = await getUserDirectory(dir: dir);

  // Define the file path
  File file = File('${userDir.path}/$fileName');

  // Check if the file exists
  return await file.exists();
}

/// Function to get the file from the user directory
Future<File> getUserFile(String fileName,{String dir = ""}) async {
  // Get the user directory
  Directory userDir = await getUserDirectory(dir: dir);

  // Define the file path
  File file = File('${userDir.path}/$fileName');

  // Check if the file exists
  if (await file.exists()) {
    return file;
  } else {
    throw Exception('File not found');
  }
}
