import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pixel_hackenbush/levels/level.dart';

class PixelHackenbush extends FlameGame {
  late final CameraComponent cam;

  @override
  Color backgroundColor() => const Color(0xff3f3851);

  final level = Level(levelName: 'level01');

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    cam = CameraComponent.withFixedResolution(
      world: level,
      width: 960,
      height: 640,
    );

    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, level]);

    return super.onLoad();
  }
}
