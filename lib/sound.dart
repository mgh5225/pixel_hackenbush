import 'package:flame_audio/flame_audio.dart';

class Sound {
  Future<void> load() async {
    await FlameAudio.audioCache.loadAll(['glow.mp3']);
  }

  void playBackground(bool isMuted) {
    FlameAudio.bgm.play('glow.mp3', volume: isMuted ? 0 : 0.5);
  }

  void mute() {
    FlameAudio.bgm.audioPlayer.setVolume(0);
  }

  void unmute() {
    FlameAudio.bgm.audioPlayer.setVolume(0.5);
  }
}
