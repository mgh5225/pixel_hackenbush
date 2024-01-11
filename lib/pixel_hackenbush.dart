import 'dart:async';
import 'dart:io' show Platform;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:pixel_hackenbush/components/enemy.dart';
import 'package:pixel_hackenbush/components/menu.dart';
import 'package:pixel_hackenbush/components/player.dart';
import 'package:pixel_hackenbush/components/level.dart';

enum PixelColors { dark }

class PixelHackenbush extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  late final CameraComponent cam;

  final backgroundColors = {
    PixelColors.dark: const Color(0xff33323d),
  };

  @override
  Color backgroundColor() => backgroundColors[PixelColors.dark]!;

  Player player = Player(character: 'Character');
  List<Enemy> enemies = [];
  late JoystickComponent joystick;
  late HudButtonComponent jumpButton;
  late HudButtonComponent attackButton;
  bool showControls = false;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    final world = Menu(menuName: 'menu');

    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 320,
      height: 320,
    );

    cam.viewfinder.anchor = Anchor.topLeft;

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
      onPressed: () => player.setJump(true),
      onReleased: () => player.setJump(false),
      onCancelled: () => player.setJump(false),
      scale: Vector2.all(1.5),
    );
    attackButton = HudButtonComponent(
      button: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/B.png'),
        ),
      ),
      margin: const EdgeInsets.only(right: 140, bottom: 60),
      onPressed: () => player.setAttack(true),
      onReleased: () => player.setAttack(false),
      onCancelled: () => player.setAttack(false),
      scale: Vector2.all(1.5),
    );

    add(jumpButton);
    add(attackButton);
  }

  void openLevel(String levelName) {
    showControls = Platform.isAndroid;

    final level = Level(
      levelName: levelName,
      player: player,
      enemies: enemies,
    );

    cam.world = level;

    cam.viewfinder.anchor = Anchor.center;

    cam.follow(player);

    add(level);

    if (showControls) {
      _addJoystick();
      _addMobileButtons();
    }
  }
}
