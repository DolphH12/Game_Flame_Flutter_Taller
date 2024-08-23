import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:prueba_flame_taller/main.dart';

class Obstacle extends PositionComponent
    with CollisionCallbacks, HasGameRef<GameWorld> {
  final _defaultColor = Colors.cyan;
  late Paint defaultPaint;
  late ShapeHitbox hitbox;

  @override
  Future<void> onLoad() async {
    size = Vector2(200, 100);
    position = game.size / 2 - size / 2;
    defaultPaint = Paint()
      ..color = _defaultColor
      ..style = PaintingStyle.fill;
    hitbox = RectangleHitbox();
    add(hitbox);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), defaultPaint);
  }
}
