import 'package:flutter/material.dart';

const appname = "Journey";
var defaultAppPath = "";
double deviceWidth = 100, deviceHeight =   100;


// Home
final drawerConstHome = {
  "Journey and Notes":Icons.book,
  "Settings":Icons.settings,
  "Manual": Icons.book_rounded
};
const bottomNavBarHome = {
  "Explore": Icons.explore, 
  "Journey/Tracing": [Icons.new_label, Icons.track_changes],
  "Profile": Icons.person
};
const floatingIconHome = Icons.location_on;
const List<double> noteDisplaySize = [240,30];

// Tracer
const bottomNavBarTracerHome = {
  "stopTracing/tracingDone": [Icons.stop,Icons.done], 
  "page/media": [Icons.book, Icons.photo],
  "select": Icons.all_out_outlined,
  "view" : Icons.remove_red_eye
};
const floatingIconTracerHome = Icons.add;
const distanceToRecord = 0.00004;

// manual editor
const bottomNavBarManualEditor = {
  "move path": Icons.moving_outlined,
  "path/page/media": [Icons.grid_goldenratio_sharp, Icons.book, Icons.photo], 
  "select": Icons.all_out_outlined,
  "deleteNode": Icons.delete,
  "view" : Icons.remove_red_eye
};
const floatingIconManualEditor = Icons.add;


// Journey and Notes

final drawerConstJN = {
  "Home":Icons.home,
  "Settings":Icons.settings
};

// path constants for database
const mediaPath = "media";
const photoPath = "$mediaPath/photo";
const audioPath = "$mediaPath/audio";
const videoPath = "$mediaPath/video";

const journeyPath = "journey";
const pageAsStoryPath = "pageNode";
const mediaAsStoryPath = "mediaNode";

// auth

const url = "http://localhost:8080";


String? imagePathConstant  = "";

String getAuthConstant(username, password){
  return "$url/user_auth?username=$username&password=$password";
}

String getMyFilesConstant(username, password){
  return "$url/get_all_files_info?username=$username&password=$password";
}

String getMyImageConstant(username, password, path){
  return "$url/images_upload_download?username=$username&password=$password&path=$path";
}

String getMyVideoConstant(username, password, path){
  return "$url/video_upload_download?username=$username&password=$password&path=$path";
}

String getMyJsonConstant(username, password, path){
  return "$url/json_upload_download?username=$username&password=$password&path=$path";
}

String getMyAnyOtherFileConstant(username, password, path){
  return "$url/any_other_file_upload_download?username=$username&password=$password&path=$path";
}

const registerUrl = "$url/user_auth";
const getKeyUrl = "$url/get_key";
const setKeyUrl = "$url/set_key";

const getAuthKeyUrl = "$url/get_auth_key";