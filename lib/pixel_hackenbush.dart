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
  final backgroundColors = {
    PixelColors.dark: const Color(0xff33323d),
    PixelColors.light: const Color(0xffe0ac74),
  };

  @override
  Color backgroundColor() => backgroundColors[PixelColors.dark]!;

  final List<Player> players = [
    Player(id: 0, character: 'Character', tagName: 'Player 1'),
    Player(id: 1, character: 'Character', tagName: 'Player 2'),
    Player(id: 2, character: 'Character', tagName: 'Player 3'),
  ];
  int activePlayer = 0;
  int? winnerPlayer;

  final List<String> levels = [
    'level01',
    'level02',
  ];

  int activeLevel = 0;

  late JoystickComponent joystick;
  late HudButtonComponent jumpButton;
  late HudButtonComponent attackButton;
  late HudButtonComponent homeButton;
  bool showControls = false;

  late CameraComponent overlayCamera;
  late CameraComponent gameCamera;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    final mainMenu = Menu(menuName: 'menu');

    gameCamera = CameraComponent.withFixedResolution(
      world: mainMenu,
      width: 320,
      height: 320,
    );
    overlayCamera = CameraComponent.withFixedResolution(
      width: 320,
      height: 320,
    );

    gameCamera.viewfinder.anchor = Anchor.topLeft;
    overlayCamera.viewfinder.anchor = Anchor.topLeft;

    addAll([gameCamera, overlayCamera, mainMenu]);

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
        getActivePlayer().horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        getActivePlayer().horizontalMovement = 1;
        break;
      default:
        getActivePlayer().horizontalMovement = 0;
    }
  }

  void _addMobileButtons() {
    jumpButton = HudButtonComponent(
      button: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/A.png'),
        ),
      ),
      margin: const EdgeInsets.only(right: 80, bottom: 80),
      onPressed: () => getActivePlayer().setJump(true),
      onReleased: () => getActivePlayer().setJump(false),
      onCancelled: () => getActivePlayer().setJump(false),
      scale: Vector2.all(1.5),
    );
    attackButton = HudButtonComponent(
      button: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/B.png'),
        ),
      ),
      margin: const EdgeInsets.only(right: 32, bottom: 32),
      onPressed: () => getActivePlayer().setAttack(true),
      onReleased: () => getActivePlayer().setAttack(false),
      onCancelled: () => getActivePlayer().setAttack(false),
      scale: Vector2.all(1.5),
    );

    add(jumpButton);
    add(attackButton);
  }

  void _addHomeButton() {
    homeButton = HudButtonComponent(
      button: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/X.png'),
        ),
      ),
      margin: const EdgeInsets.only(top: 32, left: 32),
      onPressed: () => openMenu('menu'),
      scale: Vector2.all(1.5),
    );
    add(homeButton);
  }

  void openMenu(
    String menuName, {
    int pageIdx = 0,
    bool isOverlay = false,
    String text = '',
  }) {
    final menu = Menu(
      menuName: menuName,
      pageIdx: pageIdx,
    );

    if (!isOverlay) {
      reset();

      gameCamera.world = menu;

      gameCamera.moveTo(Vector2.zero());

      gameCamera.viewfinder.anchor = Anchor.topLeft;
    } else {
      overlayCamera.world = menu;
    }
    add(menu);
  }

  void openLevel(int idx) {
    reset();

    setActiveLevel(idx);

    showControls = Platform.isAndroid || true;

    final level = Level(levelName: getActiveLevel());

    gameCamera.world = level;

    gameCamera.viewfinder.anchor = Anchor.center;

    gameCamera.follow(getActivePlayer(), maxSpeed: 100);

    add(level);

    if (showControls) {
      _addJoystick();
      _addMobileButtons();
    }

    _addHomeButton();
  }

  Player getNextPlayer(int idx) {
    final nextIdx = (idx + 1) % players.length;
    return players[nextIdx];
  }

  int getNextLevel({int? idx}) {
    idx ??= activeLevel;

    final nextIdx = (idx + 1) % levels.length;
    return nextIdx;
  }

  void setActiveLevel(int idx) {
    activeLevel = idx;
    activeLevel %= levels.length;
  }

  String getActiveLevel() {
    return levels[activeLevel];
  }

  void setActivePlayer(int idx) {
    getActivePlayer().stop();

    activePlayer = idx;
    activePlayer %= players.length;

    gameCamera.follow(getActivePlayer(), maxSpeed: 100);
  }

  Player getActivePlayer() {
    return players[activePlayer];
  }

  void reset() {
    removeAll(children.where((c) => c is! CameraComponent));
    showControls = false;
    activePlayer = 0;
    winnerPlayer = null;
    Enemy.canHit = true;
  }

  void setWinner(int idx) {
    winnerPlayer = idx;
  }

  String getText(String actionType) {
    if (actionType == 'Winner') {
      if (winnerPlayer != null) {
        return '${players[winnerPlayer!].tagName} Won!';
      }
      return 'Nobody Won!';
    }

    return 'Text Not Found';
  }
}
