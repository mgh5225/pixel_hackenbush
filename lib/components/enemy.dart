import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_hackenbush/components/hitbox.dart';
import 'package:pixel_hackenbush/components/level.dart';
import 'package:pixel_hackenbush/pixel_hackenbush.dart';

enum EnemyType { head_1, head_2, head_3 }

enum EnemyPositionType { head, middle }

enum EnemyState { idle, hit }

class Enemy extends SpriteAnimationGroupComponent
    with
        HasGameReference<PixelHackenbush>,
        CollisionCallbacks,
        HasWorldReference<Level> {
  final int id;
  final EnemyType enemyType;
  final EnemyPositionType enemyPositionType;
  final int? topId;

  Enemy({
    required this.id,
    required this.enemyType,
    required this.enemyPositionType,
    this.topId,
    position,
    priority,
  }) : super(position: position, priority: priority);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation hitAnimation;
  late RectHitbox hitbox;
  final double stepTime = 0.05;

  static bool canHit = true;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    _fixHitbox();

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));

    anchor = Anchor(
      (hitbox.width / 2 + hitbox.offsetX) / width,
      (hitbox.height / 2) / height,
    );

    return super.onLoad();
  }

  void _loadAllAnimations() {
    late String idleName, hitName;
    late Vector2 textureSize;

    switch (enemyPositionType) {
      case EnemyPositionType.head:
        idleName = 'Idle 1';
        hitName = 'Hit 1';
        break;
      case EnemyPositionType.middle:
        idleName = 'Idle 2';
        hitName = 'Hit 2';
        break;
    }

    switch (enemyType) {
      case EnemyType.head_1:
        textureSize = Vector2(60, 32);
        break;
      case EnemyType.head_2:
        textureSize = Vector2(24, 32);
        break;
      case EnemyType.head_3:
        textureSize = Vector2(30, 32);
        break;
    }

    idleAnimation = _spriteAnimation(idleName, textureSize, 1);
    hitAnimation = _spriteAnimation(hitName, textureSize, 4, loop: false);

    animations = {
      EnemyState.idle: idleAnimation,
      EnemyState.hit: hitAnimation,
    };

    current = EnemyState.idle;

    animationTickers?[EnemyState.hit]?.onComplete = () => kill();
  }

  SpriteAnimation _spriteAnimation(
    String state,
    Vector2 textureSize,
    int amount, {
    bool loop = true,
  }) {
    late String enemyTypeStr;

    switch (enemyType) {
      case EnemyType.head_1:
        enemyTypeStr = 'Head 1';
        break;
      case EnemyType.head_2:
        enemyTypeStr = 'Head 2';
        break;
      case EnemyType.head_3:
        enemyTypeStr = 'Head 3';
        break;
    }

    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Totems/$enemyTypeStr/$state.png'),
      SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: textureSize,
          loop: loop),
    );
  }

  void _fixHitbox() {
    switch (enemyType) {
      case EnemyType.head_1:
        hitbox = RectHitbox(
          offsetX: 14,
          offsetY: 10,
          width: 20,
          height: 20,
        );
        break;
      case EnemyType.head_2:
        hitbox = RectHitbox(
          offsetX: 0,
          offsetY: 10,
          width: 20,
          height: 20,
        );
        break;
      case EnemyType.head_3:
        hitbox = RectHitbox(
          offsetX: 6,
          offsetY: 10,
          width: 20,
          height: 20,
        );
        break;
    }
  }

  void hit({bool isHitByPlayer = true}) {
    if ((canHit && enemyType.index == game.getActivePlayer().id) ||
        !isHitByPlayer) {
      current = EnemyState.hit;
      canHit = false;
    }
  }

  void kill() {
    world.enemies.remove(id);
    world.removeTarget(enemyType.index);

    if (topId != null && world.enemies.containsKey(topId)) {
      world.enemies[topId]!.hit(isHitByPlayer: false);
    } else {
      final int? idx = world.getNextPlayer();
      if (idx != null) {
        game.setActivePlayer(idx);
        canHit = true;
      } else {
        world.setWinner(game.getActivePlayer().id);
      }
    }
    removeFromParent();
  }
}
