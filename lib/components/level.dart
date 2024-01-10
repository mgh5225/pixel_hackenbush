import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_hackenbush/components/collision_block.dart';
import 'package:pixel_hackenbush/components/enemy.dart';
import 'package:pixel_hackenbush/components/player.dart';

class Level extends World {
  final String levelName;
  final Player player;
  final List<Enemy> enemies;
  Level({
    required this.levelName,
    required this.player,
    required this.enemies,
  });

  late TiledComponent level;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(32));

    add(level);

    _spawnObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _spawnObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(
              spawnPoint.x,
              spawnPoint.y,
            );
            add(player);
            break;
          case 'Enemy':
            final enemyTypeStr = spawnPoint.properties.getValue<String>('Type');
            final enemyPositionTypeStr =
                spawnPoint.properties.getValue<String>('Position');

            EnemyType enemyType;
            EnemyPositionType enemyPositionType;

            switch (enemyTypeStr) {
              case 'Head 1':
                enemyType = EnemyType.head_1;
                break;
              case 'Head 2':
                enemyType = EnemyType.head_2;
                break;
              case 'Head 3':
                enemyType = EnemyType.head_3;
                break;
              default:
                enemyType = EnemyType.head_1;
            }

            switch (enemyPositionTypeStr) {
              case 'Head':
                enemyPositionType = EnemyPositionType.head;
                break;
              case 'Middle':
                enemyPositionType = EnemyPositionType.middle;
                break;
              default:
                enemyPositionType = EnemyPositionType.head;
            }

            final enemy = Enemy(
              enemyType: enemyType,
              enemyPositionType: enemyPositionType,
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ),
            );
            enemies.add(enemy);
            add(enemy);
            break;
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              blockType: CollisionBlockType.platform,
            );
            add(platform);
            break;
          case 'Wall':
            final wall = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              blockType: CollisionBlockType.wall,
            );
            add(wall);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            add(block);
        }
      }
    }
  }
}
