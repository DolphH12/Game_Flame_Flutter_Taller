import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:prueba_flame_taller/obstacles/obstacle.dart';
import 'package:prueba_flame_taller/players/player.dart';

void main() {
  runApp(GameWidget(game: GameWorld()));
}

class GameWorld extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late SpriteComponent background;
  late Player player;
  late Obstacle obstacle;

  @override
  Future<void> onLoad() async {
    background = SpriteComponent()
      ..sprite = await loadSprite('background.webp')
      ..size = size;

    player = Player();
    obstacle = Obstacle();

    player.priority = 1;
    obstacle.priority = 1;

    player.debugMode = true;
    obstacle.debugMode = true;

    add(background);
    add(obstacle);
    add(player);

    return super.onLoad();
  }
}
