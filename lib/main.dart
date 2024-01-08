import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_hackenbush/pixel_hackenbush.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  PixelHackenbush game = PixelHackenbush();

  runApp(GameWidget(game: kDebugMode ? PixelHackenbush() : game));
}
