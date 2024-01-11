import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/input.dart';
import 'package:flame/text.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_hackenbush/pixel_hackenbush.dart';

class Menu extends World with HasGameRef<PixelHackenbush> {
  final String menuName;

  Menu({
    required this.menuName,
  });

  late TiledComponent menu;

  @override
  FutureOr<void> onLoad() async {
    menu = await TiledComponent.load('$menuName.tmx', Vector2.all(32));

    add(menu);

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
      for (final button in buttonsLayer.objects) {
        late Component child;

        switch (button.class_) {
          case 'Icon':
            child = SpriteComponent(
              sprite: Sprite(game.images
                  .fromCache('UI/Small Text/Small Icons/${button.name}.png')),
              anchor: Anchor.center,
              position: Vector2(
                button.width / 2,
                button.height / 2,
              ),
              scale: Vector2.all(2),
            );
            break;
          default:
            child = TextComponent(
              text: button.name,
              textRenderer: minecraft,
              anchor: Anchor.center,
              position: Vector2(
                button.width / 2,
                button.height / 2,
              ),
            );
        }

        final btn = SpriteButtonComponent(
            button: Sprite(
              _createButton(
                button.width ~/ 14 - 1,
                button.height ~/ 14 - 1,
              ),
            ),
            position: Vector2(button.x, button.y),
            children: [child],
            onPressed: () {
              if (button.name == 'Play') game.openLevel('level01');
            });
        add(btn);
      }
    }
  }

  Image _createButton(int width, int height) {
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
