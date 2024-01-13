import 'dart:async';

import 'package:url_launcher/url_launcher.dart';
import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/input.dart';
import 'package:flame/text.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_hackenbush/pixel_hackenbush.dart';

class Menu extends World with HasGameReference<PixelHackenbush> {
  final String menuName;
  final int pageIdx;

  Menu({
    required this.menuName,
    this.pageIdx = 0,
  });

  late TiledComponent menu;

  final int maxLevelsPerPage = 12;
  int totalLevels = 0;

  @override
  FutureOr<void> onLoad() async {
    menu = await TiledComponent.load('$menuName.tmx', Vector2.all(32));

    add(menu);

    totalLevels = pageIdx * maxLevelsPerPage;

    _addButtons();

    return super.onLoad();
  }

  void _addButtons() {
    final buttonsLayer = menu.tileMap.getLayer<ObjectGroup>('Buttons');

    final minecraft = TextPaint(
      style: TextStyle(
        color: game.backgroundColors[PixelColors.dark],
        fontFamily: 'Minecraft',
        fontSize: 16,
      ),
    );

    if (buttonsLayer != null) {
      for (final object in buttonsLayer.objects) {
        late PositionComponent child1, child2;

        final action = object.properties.getValue<String>('Action');
        final actionType = object.properties.getValue<String>('ActionType');
        final actionMode = object.properties.getValue<String>('ActionMode');

        switch (object.class_) {
          case 'Text':
            final text = TextComponent(
              text: game.getText(actionType!),
              anchor: Anchor.center,
              textRenderer: minecraft,
              position: Vector2(
                object.width / 2 + object.x,
                object.height / 2 + object.y,
              ),
            );
            add(text);
            continue;
          case 'Icon':
            String icon = object.name;
            if (actionType == 'Toggle') {
              final icons = object.name.split(',');
              icon = icons[0];

              child2 = SpriteComponent(
                sprite: Sprite(game.images
                    .fromCache('UI/Small Text/Small Icons/${icons[1]}.png')),
                anchor: Anchor.center,
                position: Vector2(
                  object.width / 2,
                  object.height / 2,
                ),
                scale: Vector2.all(2),
              );
            }

            child1 = SpriteComponent(
              sprite: Sprite(
                  game.images.fromCache('UI/Small Text/Small Icons/$icon.png')),
              anchor: Anchor.center,
              position: Vector2(
                object.width / 2,
                object.height / 2,
              ),
              scale: Vector2.all(2),
            );
            break;
          default:
            String name = object.name;

            if (actionType == 'Level') {
              name = '${int.parse(name) + pageIdx * maxLevelsPerPage}';
            }

            child1 = TextComponent(
              text: name,
              textRenderer: minecraft,
              anchor: Anchor.center,
              position: Vector2(
                object.width / 2,
                object.height / 2,
              ),
            );
        }

        late PositionComponent btn;

        switch (actionType) {
          case 'Toggle':
            bool flip = false;
            if (actionMode == 'Sound') {
              flip = !game.isMuted;
            }

            btn = ToggleButtonComponent(
                position: Vector2(object.x, object.y),
                defaultSkin: SpriteComponent(
                  sprite: Sprite(
                    _createButtonUI(
                      object.width ~/ 14 - 1,
                      object.height ~/ 14 - 1,
                    ),
                  ),
                ),
                defaultSelectedSkin: SpriteComponent(
                  sprite: Sprite(
                    _createButtonUI(
                      object.width ~/ 14 - 1,
                      object.height ~/ 14 - 1,
                    ),
                  ),
                ),
                defaultLabel: flip ? child2 : child1,
                defaultSelectedLabel: flip ? child1 : child2,
                onPressed: () {
                  if (actionMode == 'Sound') {
                    if (game.isMuted) {
                      game.unmute();
                    } else {
                      game.mute();
                    }
                  }
                });

            break;
          default:
            btn = SpriteButtonComponent(
                button: Sprite(
                  _createButtonUI(
                    object.width ~/ 14 - 1,
                    object.height ~/ 14 - 1,
                  ),
                ),
                position: Vector2(object.x, object.y),
                children: [child1],
                onPressed: () async {
                  if (actionType == 'Play') game.openLevel();
                  if (actionType == 'Menu') game.openMenu(action!);
                  if (actionType == 'Url') {
                    final uri = Uri.parse(action!);
                    await launchUrl(uri);
                  }
                  if (actionType == 'Level') {
                    final levelIdx =
                        int.parse(object.name) + pageIdx * maxLevelsPerPage - 1;
                    game.openLevel(idx: levelIdx);
                  }
                  if (actionType == 'Page') {
                    if (actionMode == 'Prev') {
                      game.openMenu(
                        action!,
                        pageIdx: pageIdx - 1,
                      );
                    }
                    if (actionMode == 'Next') {
                      game.openMenu(
                        action!,
                        pageIdx: pageIdx + 1,
                      );
                    }
                  }
                  if (actionType == 'Continue') {
                    game.openLevel(idx: game.getNextLevel());
                  }
                });
        }

        if (actionType == 'Level') {
          if (totalLevels == game.levels.length) continue;
          totalLevels += 1;
        }

        if (actionType == 'Page') {
          if (actionMode == 'Prev' && pageIdx == 0) continue;
          if (actionMode == 'Next' &&
              pageIdx == game.levels.length ~/ maxLevelsPerPage) {
            continue;
          }
        }

        add(btn);
      }
    }
  }

  Image _createButtonUI(int width, int height) {
    final buttonComposImage = ImageComposition()
      ..add(
        game.images.fromCache('UI/Yellow Button/8.png'),
        Vector2(0, 0),
      )
      ..add(
        game.images.fromCache('UI/Yellow Button/10.png'),
        Vector2(width * 14, 0),
      )
      ..add(
        game.images.fromCache('UI/Yellow Button/14.png'),
        Vector2(0, height * 14),
      )
      ..add(
        game.images.fromCache('UI/Yellow Button/16.png'),
        Vector2(width * 14, height * 14),
      );

    if (width > 1) {
      for (int i = 1; i < width; i++) {
        buttonComposImage.add(
          game.images.fromCache('UI/Yellow Button/9.png'),
          Vector2(i * 14, 0),
        );
        buttonComposImage.add(
          game.images.fromCache('UI/Yellow Button/15.png'),
          Vector2(i * 14, height * 14),
        );
      }
    }

    if (height > 1) {
      for (int i = 1; i < height; i++) {
        buttonComposImage.add(
          game.images.fromCache('UI/Yellow Button/11.png'),
          Vector2(0, i * 14),
        );
        buttonComposImage.add(
          game.images.fromCache('UI/Yellow Button/13.png'),
          Vector2(width * 14, i * 14),
        );
      }
    }

    if (width > 1 && height > 1) {
      for (int i = 1; i < width; i++) {
        for (int j = 1; j < height; j++) {
          buttonComposImage.add(
            game.images.fromCache('UI/Yellow Button/12.png'),
            Vector2(i * 14, j * 14),
          );
        }
      }
    }

    return buttonComposImage.composeSync();
  }
}
