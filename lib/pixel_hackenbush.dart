import 'dart:async';
import 'dart:io' show Platform;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:pixel_hackenbush/components/enemy.dart';
import 'package:pixel_hackenbush/components/player.dart';
import 'package:pixel_hackenbush/components/level.dart';

class PixelHackenbush extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  late final CameraComponent cam;

  @override
  Color backgroundColor() => const Color(0xff33323d);

  Player player = Player(character: 'Character');
  List<Enemy> enemies = [];
  late JoystickComponent joystick;
  late HudButtonComponent jumpButton;
  late HudButtonComponent attackButton;
  bool showControls = Platform.isAndroid;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    final world = Level(
      levelName: 'level01',
      player: player,
      enemies: enemies,
    );

    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 256,
      height: 256,
    );

    cam.follow(player, maxSpeed: 150, snap: false);

    addAll([cam, world]);

    if (showControls) {
      _addJoystick();
      _addMobileButtons();
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      _readJoystick();
    }
    super.update(dt);
  }

  void _addJoystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    add(joystick);
  }

  void _readJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
    }
  }

  void _addMobileButtons() {
    jumpButton = HudButtonComponent(
      button: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/A.png'),
        ),
      ),
      margin: const EdgeInsets.only(right: 100, bottom: 100),
      onPressed: () => player.hasJumped = true,
      onReleased: () => player.hasJumped = false,
    );
    attackButton = HudButtonComponent(
      button: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/B.png'),
        ),
      ),
      margin: const EdgeInsets.only(right: 128, bottom: 72),
      onPressed: () => player.hasAttacked = true,
      onReleased: () => player.hasAttacked = false,
    );

    add(jumpButton);
    add(attackButton);
  }
}
