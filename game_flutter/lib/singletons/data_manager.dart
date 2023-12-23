import 'package:image/image.dart' as image_plugin;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game_flutter/helpers/model.dart';

class DataManager {
  DataManager._internal();

  static final DataManager instance = DataManager._internal();
  factory DataManager() {
    return instance;
  }

  static image_plugin.Image? puzzlesImage;
  static List<PuzzleSource>? puzzleSources;
  static int? totalGrid;
  static SharedPreferences? prefs;
}
