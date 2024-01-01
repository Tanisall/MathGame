import 'package:just_audio/just_audio.dart';

class SoundManager {
  SoundManager._internal();

  static final SoundManager instance = SoundManager._internal();
  factory SoundManager() {
    return instance;
  }

  static AudioPlayer poolMusic = AudioPlayer();
  static AudioPlayer poolSfx = AudioPlayer();

  static Map<String, double> volume = {
    "sfx": 0,
    "music": 0,
  };

  static void moveTile() {}

  static void playSuccess() {}
}
