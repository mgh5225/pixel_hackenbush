import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_hackenbush/pixel_hackenbush.dart';
import 'package:pixel_hackenbush/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  final pref = await SharedPreferences.getInstance();
  final storage = Storage(pref);

  PixelHackenbush game = PixelHackenbush(storage: storage);

  runApp(
      GameWidget(game: kDebugMode ? PixelHackenbush(storage: storage) : game));
}
