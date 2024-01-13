import 'package:shared_preferences/shared_preferences.dart';

enum StorageKeys { isMuted, activeLevel }

class Storage {
  Storage(SharedPreferences pref) {
    isMuted = pref.getBool(StorageKeys.isMuted.name) ?? false;
    activeLevel = pref.getInt(StorageKeys.activeLevel.name) ?? 0;
  }

  late bool isMuted;
  late int activeLevel;

  Future<void> setIsMuted(isMuted) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(StorageKeys.isMuted.name, isMuted);
    this.isMuted = isMuted;
  }

  Future<void> setActiveLevel(activeLevel) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setInt(StorageKeys.activeLevel.name, activeLevel);
    this.activeLevel = activeLevel;
  }
}
