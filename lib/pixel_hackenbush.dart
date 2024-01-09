import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_hackenbush/components/player.dart';
import 'package:pixel_hackenbush/components/level.dart';

class PixelHackenbush extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  late final CameraComponent cam;

  @override
  Color backgroundColor() => const Color(0xff3f3851);

  Player player = Player(character: '01-King Human');
  late JoystickComponent joystick;
  bool showJoystick = true;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    final world = Level(
      levelName: 'level01',
      player: player,
    );

    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 960,
      height: 640,
    );

    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);

    if (showJoystick) {
      _addJoystick();
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) {
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
}
