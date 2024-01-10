import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_hackenbush/components/collision_block.dart';
import 'package:pixel_hackenbush/components/hitbox.dart';
import 'package:pixel_hackenbush/pixel_hackenbush.dart';

enum PlayerState { idle, run, jump, fall, attack }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelHackenbush>, KeyboardHandler, CollisionCallbacks {
  final String character;
  Player({required this.character, position}) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation attackAnimation;
  final double stepTime = 0.05;

  final double _gravity = 9.8;
  final double _jumpForce = 300;
  final double _terminalVelocity = 300;

  double horizontalMovement = 0.0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool hasAttacked = false;
  RectHitbox hitbox = RectHitbox(
    offsetX: 25,
    offsetY: 10,
    width: 15,
    height: 20,
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
      (hitbox.height + hitbox.offsetY) / height,
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _applyGravity(dt);
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
    hasAttacked = keysPressed.contains(LogicalKeyboardKey.enter);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is CollisionBlock) {
      switch (other.blockType) {
        case CollisionBlockType.platform:
          if (velocity.y > 0 &&
              other.isCollidedFromTop(
                this,
                intersectionPoints,
              )) {
            isOnGround = true;
            position.y = other.y;
            velocity.y = 0;
          }
          break;
        case CollisionBlockType.ground:
          if (velocity.x > 0 &&
              other.isCollidedFromLeft(
                this,
                intersectionPoints,
              )) {
            position.x = other.x - hitbox.width / 2;
            velocity.x = 0;
          }
          if (velocity.x < 0 &&
              other.isCollidedFromRight(
                this,
                intersectionPoints,
              )) {
            position.x = other.x + other.width + hitbox.width / 2;
            velocity.x = 0;
          }
          if (velocity.y > 0 &&
              other.isCollidedFromTop(
                this,
                intersectionPoints,
              )) {
            isOnGround = true;
            position.y = other.y;
            velocity.y = 0;
          }
          if (velocity.y < 0 &&
              other.isCollidedFromBottom(
                this,
                intersectionPoints,
              )) {
            position.y = other.y + other.height + hitbox.height;
            velocity.y = 0;
          }
          break;
        default:
      }
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is CollisionBlock) {
      isOnGround = false;
    }

    super.onCollisionEnd(other);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', Vector2(64, 40), 5);
    runAnimation = _spriteAnimation('Run', Vector2(64, 40), 6);
    jumpAnimation = _spriteAnimation('Jump', Vector2(64, 40), 3, loop: false);
    fallAnimation = _spriteAnimation('Fall', Vector2(64, 40), 1);
    attackAnimation = _spriteAnimation('Attack 1', Vector2(64, 40), 3);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.attack: attackAnimation,
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(
    String state,
    Vector2 textureSize,
    int amount, {
    bool loop = true,
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('$character/$state.png'),
      SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: textureSize,
          loop: loop),
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

    if (hasAttacked) {
      playerState = PlayerState.attack;
    }

    current = playerState;
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }
}
