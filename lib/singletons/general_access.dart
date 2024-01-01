import 'dart:ui';

import 'package:game_flutter/pages/menu.dart';
import './mobile_access.dart' if (dart.library.html) './web_access.dart'
    as my_worker;

class GeneralAccess {
  GeneralAccess._internal();

  static final GeneralAccess instance = GeneralAccess._internal();
  factory GeneralAccess() {
    return instance;
  }

  static Future<void> initiateAccess(context) async {
    my_worker
        .renderImage("assets/images/puzzle-images.png",
            size: const Size(2500, 500))
        .then((img) async {
      await my_worker.cropPuzzle(img, context, MainMenuPage());
      // await my_worker.cropPuzzle(img, context, const GameLayout());
    });
  }
}
