import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_hackenbush/pixel_hackenbush.dart';

enum PlayerState { idle, run }

enum PlayerDirection { left, right, none }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelHackenbush> {
  final String character;
  Player({required this.character, position}) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  final double stepTime = 0.075;

  PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', Vector2(78, 58), 11);
    runAnimation = _spriteAnimation('Run', Vector2(78, 58), 8);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
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
}
