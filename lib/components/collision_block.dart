import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_hackenbush/components/player.dart';

enum CollisionBlockType { ground, platform }

class CollisionBlock extends PositionComponent {
  final CollisionBlockType blockType;
  CollisionBlock({
    position,
    size,
    this.blockType = CollisionBlockType.ground,
  }) : super(position: position, size: size);

  final Vector2 fromTop = Vector2(0, -1);
  final Vector2 fromBottom = Vector2(0, 1);
  final Vector2 fromLeft = Vector2(-1, 0);
  final Vector2 fromRight = Vector2(1, 0);

  final double topAlpha = 0.5;
  final double bottomAlpha = 0.5;
  final double leftAlpha = 0.8;
  final double rightAlpha = 0.8;

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(
      collisionType: CollisionType.passive,
    ));
    return super.onLoad();
  }

  bool isCollidedFromTop(Player player, Set<Vector2> points) {
    final playerY = player.position.y;
    final playerHeight = player.hitbox.height;

    bool res = false;
    Vector2 midBlock = Vector2.zero();

    for (final point in points) {
      final blockY = point.y;
      res = res || playerY > blockY && playerY + playerHeight < y + height;

      midBlock += point;
    }

    midBlock = midBlock / points.length.toDouble();

    final collisionNormal = player.absoluteCenter - midBlock;
    collisionNormal.normalize();

    return res && fromTop.dot(collisionNormal) > topAlpha;
  }

  bool isCollidedFromBottom(Player player, Set<Vector2> points) {
    final playerHeight = player.hitbox.height;
    final playerY = player.position.y + playerHeight;

    bool res = false;
    Vector2 midBlock = Vector2.zero();

    for (final point in points) {
      final blockY = point.y;
      res = res || playerY > blockY;

      midBlock += point;
    }

    midBlock = midBlock / points.length.toDouble();

    final collisionNormal = player.absoluteCenter - midBlock;
    collisionNormal.normalize();

    return res && fromBottom.dot(collisionNormal) > bottomAlpha;
  }

  bool isCollidedFromLeft(Player player, Set<Vector2> points) {
    final playerWidth = player.hitbox.width;
    double playerX = player.position.x + playerWidth / 2;

    if (player.scale.x < 0) playerX -= playerWidth;

    bool res = false;
    Vector2 midBlock = Vector2.zero();

    for (final point in points) {
      final blockX = point.x;
      res = res || playerX > blockX;

      midBlock += point;
    }

    midBlock = midBlock / points.length.toDouble();

    final collisionNormal = player.absoluteCenter - midBlock;
    collisionNormal.normalize();

    return res && fromLeft.dot(collisionNormal) > leftAlpha;
  }

  bool isCollidedFromRight(Player player, Set<Vector2> points) {
    final playerWidth = player.hitbox.width;
    double playerX = player.position.x - playerWidth;

    if (player.scale.x < 0) playerX -= playerWidth;

    bool res = false;
    Vector2 midBlock = Vector2.zero();

    for (final point in points) {
      final blockX = point.x;
      res = res || playerX < blockX;

      midBlock += point;
    }
    midBlock = midBlock / points.length.toDouble();

    final collisionNormal = player.absoluteCenter - midBlock;
    collisionNormal.normalize();

    return res && fromRight.dot(collisionNormal) > rightAlpha;
  }
}
