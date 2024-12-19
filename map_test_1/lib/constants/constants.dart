import 'package:flutter/material.dart';

const appname = "Journey";
var defaultAppPath = "";
double deviceWidth = 100, deviceHeight =   100;


// Home
final drawerConstHome = {
  "Journey and Notes":Icons.book,
  "Settings":Icons.settings
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
  "media": Icons.camera,
  "Home": Icons.home
};
const floatingIconTracerHome = Icons.add;

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