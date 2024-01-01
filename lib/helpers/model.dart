// ignore_for_file: depend_on_referenced_packages

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as imagedart;

import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:game_flutter/statics/function.dart';

enum ActionControl { move, rotate }

class PuzzleImage {
  late String name;
  bool selected = false;

  PuzzleImage(this.name);

  void selectImage(bool selected) => this.selected = selected;
}

class Box with ChangeNotifier {
  bool isEmpty = false;
  late Offset offset;
  int quarterTurn = 0;
  int quarterTurnCorrect = 0;
  late int index;
  late int indexCorrect;
  Size? size;

  Image? img;

  Box({required this.indexCorrect, this.size, this.quarterTurn = 0}) {
    index = indexCorrect;
  }

  void setIndex(int index) => this.index = index;
  void setSize(Size size) => this.size = size;
  void setOffset(Offset offset) => this.offset = offset;
  void generateOffset(int numBox, double sizeMax) => offset = Offset(
      (index % numBox) * sizeMax / numBox,
      (index ~/ numBox) * sizeMax / numBox);
  void setImg(Image? img) => this.img = img;

  void setEmpty(bool isEmpty) => this.isEmpty = isEmpty;

  bool isSameLine(int index, int numBox) =>
      index ~/ numBox == this.index ~/ numBox ||
      index % numBox == this.index % numBox;

  void moveIndex(int direction, int newEmptykey, Axis axis, int numBox) {
    index += axis == Axis.horizontal ? 1 * direction : numBox * direction;
  }

  bool isCorrect() =>
      index == indexCorrect && quarterTurn == quarterTurnCorrect;

  void rotateBoxTurn() {
    quarterTurn = (quarterTurn + 1) > 3 ? 0 : quarterTurn + 1;
  }

  void randomRotate() {
    if (isEmpty == false) quarterTurn = math.Random().nextInt(4);
  }
}

class PlanetObj {
  Image img;
  Alignment? align;
  double? left;
  double? right;
  double? top;
  double? bottom;
  double sigma;

  PlanetObj(this.img,
      {this.align,
      this.left,
      this.right,
      this.bottom,
      this.top,
      this.sigma = 0.9});

  Widget widget([double delay = 0]) {
    Widget widgetTemp = ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: Bounce(
        child: img,
        duration: Duration(milliseconds: delay.toInt()),
      ),
    );

    return this.align != null
        ? Align(child: widgetTemp, alignment: align!)
        : Positioned(
            child: widgetTemp,
            left: left,
            right: right,
            bottom: bottom,
            top: top,
          );
  }
}

// class EnemyPlace {
//   double percentPoint;
//   String name;
//   String assetPath;
//   bool show = false;
//   bool complete = false;
//   Offset? offset;

//   EnemyPlace(this.percentPoint, this.name, this.assetPath);

//   bool get isComplete => complete;
//   setOffset(Offset offset) => this.offset = offset;
//   setShow(bool show) => this.show = show;
//   setComplete(bool complete) => this.complete = complete;
// }

class EnemyPlace {
  double percentPoint;
  imagedart.Image? image;
  Uint8List? imageByte;
  bool show = false;
  bool complete = false;
  Offset? offset;

  EnemyPlace(this.percentPoint);

  bool get isComplete => complete;
  setOffset(Offset offset) => this.offset = offset;
  setImageByte(Uint8List imageByte) {
    this.imageByte = imageByte;
  }

  setShow(bool show) => this.show = show;
  setComplete(bool complete) => this.complete = complete;

  getImagePath(double resizeScale) {
    return Image.memory(
      imageByte!,
      width: 100 * resizeScale,
    );
  }

  getImagePopup(double resizeScale) {
    return Image.memory(
      imageByte!,
      width: 300 * resizeScale,
    );
  }

  List<Image> getImageCrop(double resizeScale, {int totalRowCol = 4}) {
    // var la = List<Uint8List>.from(
    //     StaticFunc.buildCropImages(image!, totalRowCol, returnDataList: true));
    // return la;
    return List<Image>.from(StaticFunc.buildCropImages(image!, totalRowCol));
  }

  void setImage(imagedart.Image cropImage) {
    image = cropImage;
  }
}

class PuzzleSource {
  imagedart.Image? image;
  Uint8List? imageByte;

  PuzzleSource(this.image, this.imageByte);

  setImageByte(imageByte) => this.imageByte = imageByte;

  generateImageByte() =>
      imageByte = Uint8List.fromList(imagedart.encodePng(image!));
}

class Star {
  double degree = 0;
  Offset offset;
  double scale;
  double? scaleMax;
  double opacity;
  bool scaleType = math.Random().nextBool();

  Star({required this.offset, required this.scale, required this.opacity});

  void setMeter({rate = 0.01}) {
    scaleMax ??= scale;
    double tempScale = scale + (scaleType ? rate : -rate);

    if (tempScale > scaleMax! || tempScale < 0) {
      scale = tempScale > scaleMax! ? scaleMax! : 0;
      scaleType = !scaleType;
    } else {
      scale = tempScale;
    }

    opacity = scale / scaleMax! * scaleMax!;

    if (scale == 0) {
      scaleMax = math.Random().nextInt(10) / 9 * 0.4 + 0.5;
      offset = Offset(math.Random().nextDouble(), math.Random().nextDouble());
    }

    // if (tempOpacity > 1 || tempOpacity < 0) {
    //   opacity = tempOpacity > 1 ? 1 : 0;
    //   opacityType = !opacityType;
    // } else {
    //   opacity = tempOpacity;
    // }
  }
}

class MainMenuSetting {
  int level;
  double height;

  MainMenuSetting(this.level, this.height);
}

enum GameStatus {
  start,
  random,
  playing,
  complete,
}

class MainMenu {
  int index;
  String text;
  bool selected;

  MainMenu(this.index, this.text, {this.selected = false});

  void setSelected(bool selected) => this.selected = selected;
}

class InfoGame {
  String? title;
  int tiles;
  int move;

  InfoGame({
    this.title = "Math Puzzle",
    this.tiles = 0,
    this.move = 0,
  });

  updateData({
    String? title,
    int? tiles,
    int? move = -1,
  }) {
    int moveTemp = move ?? -1;

    this.title = title ??= this.title;
    this.tiles = tiles ??= this.tiles;

    if (move != -1) {
      this.move = moveTemp == 0 ? 0 : this.move + 1;
    }
  }
}
