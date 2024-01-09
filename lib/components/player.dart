import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_hackenbush/components/collision_block.dart';
import 'package:pixel_hackenbush/components/player_hitbox.dart';
import 'package:pixel_hackenbush/pixel_hackenbush.dart';

enum PlayerState { idle, run, jump, fall }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelHackenbush>, KeyboardHandler, CollisionCallbacks {
  final String character;
  Player({required this.character, position}) : super(position: position) {
    debugMode = true;
  }

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  final double stepTime = 0.075;

  final double _gravity = 9.8;
  final double _jumpForce = 460;
  final double _terminalVelocity = 300;

  double horizontalMovement = 0.0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 20,
    offsetY: 20,
    width: 20,
    height: 25,
  );

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));

    anchor = Anchor(
      (hitbox.width / 2 + hitbox.offsetX) / width,
      (hitbox.height + hitbox.offsetX) / height,
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    // _checkHorizontalCollisions();
    _applyGravity(dt);
    // _checkVerticalCollisions();
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;

    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is CollisionBlock) {
      switch (other.blockType) {
        case CollisionBlockType.ground:
          if (velocity.y > 0) {
            isOnGround = true;
          }
          velocity.y = 0;
          break;
        case CollisionBlockType.wall:
          if (velocity.x > 0) {
            position.x = other.x - hitbox.width / 2;
          }
          if (velocity.x < 0) {
            position.x = other.x + other.width + hitbox.width / 2;
          }
          velocity.x = 0;
          break;
        default:
      }
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is CollisionBlock) {
      switch (other.blockType) {
        case CollisionBlockType.ground:
          isOnGround = false;
          break;
        default:
      }
    }

    super.onCollisionEnd(other);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', Vector2(78, 58), 11);
    runAnimation = _spriteAnimation('Run', Vector2(78, 58), 8);
    jumpAnimation = _spriteAnimation('Jump', Vector2(78, 58), 1);
    fallAnimation = _spriteAnimation('Fall', Vector2(78, 58), 1);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation,
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(
    String state,
    Vector2 textureSize,
    int amount,
  ) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(
        '$character/$state (${textureSize.x.toInt()}x${textureSize.y.toInt()}).png',
      ),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJumped(dt);

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJumped(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    hasJumped = false;
    isOnGround = false;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontally();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontally();
    }

    if (velocity.x > 0 || velocity.x < 0) {
      playerState = PlayerState.run;
    }

    if (velocity.y > 0) {
      playerState = PlayerState.fall;
    }

    if (velocity.y < 0) {
      playerState = PlayerState.jump;
    }

    current = playerState;
  }

  void _applyGravity(double dt) {
    if (!isOnGround) {
      velocity.y += _gravity;
      velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
      position.y += velocity.y * dt;
    }
  }
}
