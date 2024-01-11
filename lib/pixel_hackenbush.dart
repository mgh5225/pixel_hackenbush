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

enum PixelColors { dark, light }

class PixelHackenbush extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  late final CameraComponent cam;

  final backgroundColors = {
    PixelColors.dark: const Color(0xff33323d),
    PixelColors.light: const Color(0xffe0ac74),
  };

  @override
  Color backgroundColor() => backgroundColors[PixelColors.dark]!;

  List<Player> players = [
    Player(id: 0, character: 'Character', tagName: 'Player 1'),
    Player(id: 1, character: 'Character', tagName: 'Player 2')
  ];
  int activePlayer = 0;

  Map<int, Enemy> enemies = {};
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
        players[activePlayer].horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        players[activePlayer].horizontalMovement = 1;
        break;
      default:
        players[activePlayer].horizontalMovement = 0;
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
      onPressed: () => players[activePlayer].setJump(true),
      onReleased: () => players[activePlayer].setJump(false),
      onCancelled: () => players[activePlayer].setJump(false),
      scale: Vector2.all(1.5),
    );
    attackButton = HudButtonComponent(
      button: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/B.png'),
        ),
      ),
      margin: const EdgeInsets.only(right: 140, bottom: 60),
      onPressed: () => players[activePlayer].setAttack(true),
      onReleased: () => players[activePlayer].setAttack(false),
      onCancelled: () => players[activePlayer].setAttack(false),
      scale: Vector2.all(1.5),
    );

    add(jumpButton);
    add(attackButton);
  }

  void openLevel(String levelName) {
    showControls = Platform.isAndroid;

    final level = Level(
      levelName: levelName,
    );

    cam.world = level;

    cam.viewfinder.anchor = Anchor.center;

    cam.follow(players[activePlayer], maxSpeed: 100);

    add(level);

    if (showControls) {
      _addJoystick();
      _addMobileButtons();
    }
  }

  void changePlayer() {
    activePlayer += 1;
    activePlayer %= players.length;

    cam.follow(players[activePlayer], maxSpeed: 100);
  }
}
