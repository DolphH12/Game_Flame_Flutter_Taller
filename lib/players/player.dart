import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';
import 'package:prueba_flame_taller/main.dart';

import '../obstacles/obstacle.dart';

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<GameWorld>, KeyboardHandler, CollisionCallbacks {
  Vector2 velocity = Vector2.zero();
  Vector2 movement = Vector2.zero();
  late ShapeHitbox shapeHitbox;

  @override
  Future<void> onLoad() async {
    await _loadAnimations();

    size = Vector2(128, 128);
    position = Vector2(0, game.size.y / 2);

    shapeHitbox = RectangleHitbox(
      size: Vector2(70, 80),
      position: Vector2(24, 34),
      collisionType: CollisionType.passive,
    );

    add(shapeHitbox);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateAnimation();
    _updateMovement(dt);
  }

  Future<void> _loadAnimations() async {
    final spriteSheetIdle = SpriteSheet(
      image: await game.images.load('1_Cat_Idle-Sheet.png'),
      srcSize: Vector2(32, 32),
    );

    final spriteSheetRun = SpriteSheet(
      image: await game.images.load('2_Cat_Run-Sheet.png'),
      srcSize: Vector2(32, 32),
    );

    animations = {
      'idle': spriteSheetIdle.createAnimation(
        stepTime: 0.1,
        from: 0,
        to: 8,
        row: 0,
      ),
      'run': spriteSheetRun.createAnimation(
        stepTime: 0.1,
        from: 0,
        to: 10,
        row: 0,
      ),
    };

    current = 'idle';
  }

  void _updateAnimation() {
    if (velocity != Vector2.zero()) {
      if (velocity.x < 0 && scale.x > 0) {
        flipHorizontallyAroundCenter();
      } else if (velocity.x > 0 && scale.x < 0) {
        flipHorizontallyAroundCenter();
      }
      current = 'run';
    } else {
      current = 'idle';
    }
  }

  void _updateMovement(double dt) {
    velocity.x = movement.x * 200;
    velocity.y = movement.y * 200;
    position.x += velocity.x * dt;
    position.y += velocity.y * dt;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    movement.x = 0;
    movement.y = 0;

    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW)) {
      movement.y += -1;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      movement.y += 1;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      movement.x += -1;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      movement.x += 1;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Obstacle) {
      position = Vector2(0, game.size.y / 2);
    }
  }
}
