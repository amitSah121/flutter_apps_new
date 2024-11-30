

import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/go_green.dart';
import 'package:flutter_application_1/joystick.dart';
import 'package:flutter_application_1/player.dart';
import 'package:flutter_application_1/text_component.dart';
import 'package:flutter/painting.dart';

class GoGreenWorld extends World with HasGameRef<GoGreen>, HasCollisionDetection{
  late var joystick;
  late Player player;
  bool joystickAdded = false;

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    // joystick = JoystickComponent(
    //   knob: CircleComponent(radius: 15, paint: Paint()..color = const Color(0xFFCCCCCC)),
    //   background: CircleComponent(radius: 15, paint: Paint()..color = const Color(0x77CCCCCC)),
    //   margin: const EdgeInsets.only(left: 40, bottom: 40),
    //   size:100.0,
    //   knobRadius: 100,
    //   position: Vector2(100, 100)
    // );


    final textComponent = createTextComponent("Hello World beauty");


    add(textComponent);

    player = Player(position: Vector2.all(0.0), radius: 50);
    add(player);
    add(Player(position: Vector2(-50.0, -50.0), radius: 20, color: Colors.red));

    // add(joystick);
  }

  
  @override
  void onGameResize(Vector2 canvasSize) async{
    super.onGameResize(canvasSize);

    // Add joystick only once the game size is established
    if (!joystickAdded) {
      final joystick = JoystickComponent(
        knob: CircleComponent(radius: 30, ),
        background: CircleComponent(radius: 100, ),
        margin: const EdgeInsets.only(left: 40, bottom: 40),
      );
      add(joystick);
      joystickAdded = true;
    }
  }


  @override
  void update(double dt) {
    super.update(dt);

    if (joystickAdded && joystick.delta != Vector2.zero()) {
      player.move(joystick.delta);
    }
  }
}