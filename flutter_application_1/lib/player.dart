import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';

class Player extends CircleComponent with HasGameRef{
  final double speed = 200;

  Player(
      {required super.position,
      required double radius,
      Color color = Colors.white})
      : super(
            anchor: Anchor.center,
            radius: radius,
            paint: Paint()
              ..color = color
              ..style = PaintingStyle.fill)
  {
    super.position.sub(Vector2(width/2, height/2));
  }

  void move(Vector2 delta) {
    position.add(delta * speed); // Move the player based on joystick input
  }
}
