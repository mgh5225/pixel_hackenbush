import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/services.dart';
import 'package:pixel_hackenbush/components/collision_block.dart';
import 'package:pixel_hackenbush/components/enemy.dart';
import 'package:pixel_hackenbush/components/hitbox.dart';
import 'package:pixel_hackenbush/pixel_hackenbush.dart';

enum PlayerState {
  idle,
  run,
  jump,
  fall,
  attack1,
  attack2,
  attack3,
  airAttack1,
  airAttack2,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelHackenbush>, KeyboardHandler, CollisionCallbacks {
  final String character;
  Player({required this.character, position}) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation attack1Animation;
  late final SpriteAnimation attack2Animation;
  late final SpriteAnimation attack3Animation;
  late final SpriteAnimation airAttack1Animation;
  late final SpriteAnimation airAttack2Animation;
  final double stepTime = 0.05;

  final double _gravity = 9.8;
  final double _jumpForce = 300;
  final double _terminalVelocity = 300;
  final double _attackRange = 20;

  double horizontalMovement = 0.0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool hasAttacked = false;
  bool canAttack = true;
  bool canChangeAnimation = true;
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

    priority = 1;

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
    canAttack = canAttack || !keysPressed.contains(LogicalKeyboardKey.enter);

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
    attack1Animation = _spriteAnimation(
      'Attack 1',
      Vector2(64, 40),
      3,
      loop: false,
    );
    attack2Animation = _spriteAnimation(
      'Attack 2',
      Vector2(64, 40),
      3,
      loop: false,
    );
    attack3Animation = _spriteAnimation(
      'Attack 3',
      Vector2(64, 40),
      3,
      loop: false,
    );
    airAttack1Animation = _spriteAnimation(
      'Air Attack 1',
      Vector2(64, 40),
      3,
      loop: false,
    );
    airAttack2Animation = _spriteAnimation(
      'Air Attack 2',
      Vector2(64, 40),
      3,
      loop: false,
    );

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.attack1: attack1Animation,
      PlayerState.attack2: attack2Animation,
      PlayerState.attack3: attack3Animation,
      PlayerState.airAttack1: airAttack1Animation,
      PlayerState.airAttack2: airAttack2Animation,
    };

    current = PlayerState.idle;

    animationTickers?[PlayerState.attack1]?.onStart = () => _onAttackStart();
    animationTickers?[PlayerState.attack2]?.onStart = () => _onAttackStart();
    animationTickers?[PlayerState.attack3]?.onStart = () => _onAttackStart();
    animationTickers?[PlayerState.airAttack1]?.onStart = () => _onAttackStart();
    animationTickers?[PlayerState.airAttack2]?.onStart = () => _onAttackStart();
    animationTickers?[PlayerState.attack1]?.onComplete =
        () => _onAttackCompleted();
    animationTickers?[PlayerState.attack2]?.onComplete =
        () => _onAttackCompleted();
    animationTickers?[PlayerState.attack3]?.onComplete =
        () => _onAttackCompleted();
    animationTickers?[PlayerState.airAttack1]?.onComplete =
        () => _onAttackCompleted();
    animationTickers?[PlayerState.airAttack2]?.onComplete =
        () => _onAttackCompleted();
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

    if (hasAttacked && canAttack) {
      final random = Random();
      if (isOnGround) {
        playerState = [
          PlayerState.attack1,
          PlayerState.attack2,
          PlayerState.attack3,
        ][random.nextInt(3)];
      } else {
        playerState = [
          PlayerState.airAttack1,
          PlayerState.airAttack2,
        ][random.nextInt(2)];
      }
      _checkForwardRay();
    }

    if (canChangeAnimation) current = playerState;
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkForwardRay() {
    final forwardRay = Ray2(
      origin: absoluteCenter + Vector2(scale.x.sign * hitbox.width, 0),
      direction: scale.x > 0 ? Vector2(1, 0) : Vector2(-1, 0),
    );

    final result = game.collisionDetection.raycast(
      forwardRay,
      maxDistance: _attackRange,
    );

    if (result != null && result.hitbox != null) {
      final hitbox = result.hitbox;
      final object = hitbox?.parent;

      if (object is Enemy) {
        object.hit();
      }
    }
  }

  void _onAttackStart() {
    canChangeAnimation = false;
    canAttack = false;
  }

  void _onAttackCompleted() {
    canChangeAnimation = true;
    canAttack = !hasAttacked;
  }
}
