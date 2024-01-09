import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_hackenbush/components/player.dart';

enum CollisionBlockType { ground, wall, platform }

class CollisionBlock extends PositionComponent {
  CollisionBlockType blockType;
  CollisionBlock({
    position,
    size,
    this.blockType = CollisionBlockType.ground,
  }) : super(position: position, size: size);

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox());
    return super.onLoad();
  }

  bool isCollidedWithPlayer(Player player) {
    final hitbox = player.hitbox;

    final playerX = player.position.x + hitbox.offsetX;
    final playerY = player.position.y + hitbox.offsetY;
    final playerWidth = hitbox.width;
    final playerHeight = hitbox.height;

    final fixedX = player.scale.x < 0
        ? playerX - (hitbox.offsetX * 2) - playerWidth
        : playerX;
    final fixedY = blockType == CollisionBlockType.platform
        ? playerY + playerHeight
        : playerY;

    return (fixedY < y + height &&
        playerY + playerHeight > y &&
        fixedX < x + width &&
        fixedX + playerWidth > x);
  }
}
