
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants.dart';


TextComponent createTextComponent(String text,{x=0.0,y=0.0,size=48.0}) {
  TextStyle? p = TextStyle(
        fontSize: size,
        color: Colors.white,
      );
  return TextComponent(
    text: text,
    position: Vector2(x-width/2, y-height/2), // Set the position on the screen
    textRenderer: TextPaint(
      style: p,
    ),
  );
}


