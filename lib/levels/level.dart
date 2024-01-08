import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_hackenbush/actors/player.dart';

class Level extends World {
  final String levelName;
  Level({required this.levelName});

  late TiledComponent level;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(32));

    add(level);

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    for (final spawnPoint in spawnPointsLayer!.objects) {
      switch (spawnPoint.class_) {
        case 'Player':
          final player = Player(
            character: '01-King Human',
            position: Vector2(
              spawnPoint.x,
              spawnPoint.y,
            ),
          );
          add(player);
          break;
      }
    }

    return super.onLoad();
  }
}
