import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/go_green_world.dart';

class GoGreen extends FlameGame {
  GoGreen()
      : super(
            world: GoGreenWorld(),
            camera: CameraComponent.withFixedResolution(
                width: width, height: height));


  @override
  Color backgroundColor() {
    return Colors.green;
  }
}
