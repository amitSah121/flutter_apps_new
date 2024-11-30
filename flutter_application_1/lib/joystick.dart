import 'package:flame/components.dart';
import 'package:flutter/material.dart';

JoystickComponent createJoystick() {
  return JoystickComponent(
    knob: CircleComponent(radius: 15, paint: Paint()..color = const Color(0xFFCCCCCC)),
    background: CircleComponent(radius: 50, paint: Paint()..color = const Color(0x77CCCCCC)),
    margin: const EdgeInsets.only(left: 20, bottom: 20),
  );
}