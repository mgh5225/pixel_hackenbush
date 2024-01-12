import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_hackenbush/components/collision_block.dart';
import 'package:pixel_hackenbush/components/enemy.dart';
import 'package:pixel_hackenbush/pixel_hackenbush.dart';

class Level extends World with HasGameRef<PixelHackenbush> {
  final String levelName;
  Level({
    required this.levelName,
  });

  late TiledComponent level;
  Map<int, Enemy> enemies = {};
  Map<int, int> targets = {};

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
            final playerId = spawnPoint.properties.getValue<int>('PlayerID');
            game.players[playerId ?? 0].position = Vector2(
              spawnPoint.x,
              spawnPoint.y,
            );
            game.players[playerId ?? 0].tagName = spawnPoint.name;
            game.players[playerId ?? 0].priority = 1;
            add(game.players[playerId ?? 0]);
            break;
          case 'Enemy':
            final enemyTypeStr = spawnPoint.properties.getValue<String>('Type');
            final enemyPositionTypeStr =
                spawnPoint.properties.getValue<String>('Position');
            final topId = spawnPoint.properties.getValue<int>('TopID');

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
              id: spawnPoint.id,
              enemyType: enemyType,
              enemyPositionType: enemyPositionType,
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ),
              topId: topId,
            );
            enemies[spawnPoint.id] = enemy;
            addTarget(enemy.enemyType.index);
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

  int? getNextPlayer() {
    int? nextIdx;
    int idx = -1;
    final currentIdx = game.getActivePlayer().id;

    while (idx != currentIdx) {
      if (idx == -1) {
        idx = game.getNextPlayer(currentIdx).id;
      } else {
        idx = game.getNextPlayer(idx).id;
      }
      if (getTarget(idx) > 0) {
        nextIdx = idx;
        break;
      }
    }
    return nextIdx;
  }

  int getTarget(int idx) {
    return targets[idx] ?? 0;
  }

  void addTarget(int idx) {
    if (targets.containsKey(idx)) {
      targets[idx] = targets[idx]! + 1;
    } else {
      targets[idx] = 1;
    }
  }

  void removeTarget(int idx) {
    if (targets.containsKey(idx)) {
      targets[idx] = targets[idx]! - 1;
    } else {
      targets[idx] = 0;
    }
  }

  void setWinner(int idx) {
    print(idx);
  }
}
