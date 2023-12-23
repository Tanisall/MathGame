import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_plugin;
import 'package:game_flutter/helpers/model.dart';
import 'package:game_flutter/singletons/data_manager.dart';

class StaticFunc {
  static List<int> encodePng(img) {
    return computeEncode(img);
  }

  static exportImageWidget(tempCrop, {Size? targetSize}) {
    return targetSize != null
        ? Image.memory(Uint8List.fromList(encodePng(tempCrop)),
            fit: BoxFit.contain,
            width: targetSize.width,
            height: targetSize.height)
        : Image.memory(Uint8List.fromList(encodePng(tempCrop)),
            fit: BoxFit.fill);
  }

  static getCropImage(
    image_plugin.Image fullImage, {
    Offset offset = Offset.zero,
    Size? size,
    Size? targetSize,
    bool returnDataList = false,
    bool returnImageData = false,
    double padding = 0,
  }) {
    image_plugin.Image? tempCrop;
    size ??= Size(fullImage.width.toDouble(), fullImage.height.toDouble());
    // if (widget.imageBckGround = null && this.fullImage != null)

    tempCrop = image_plugin.copyCrop(
      fullImage,
      (offset.dx + (padding)).round(),
      (offset.dy + (padding)).round(),
      (size.width - (padding * 2)).round(),
      (size.height - (padding * 2)).round(),
    );

    if (returnImageData) {
      return tempCrop;
    } else if (returnDataList) {
      return Uint8List.fromList(encodePng(tempCrop));
    }

    return exportImageWidget(tempCrop, targetSize: targetSize);
  }

  static List<dynamic> buildCropImages(
    image_plugin.Image img,
    int total, {
    bool returnDataList = false,
    bool returnImageData = false,
    Size? targetSize,
    double padding = 0,
    int? totalRender,
    bool heightSameWidth = false,
  }) {
    List<dynamic> puzzleImages = [];
    totalRender ??= pow(total, 2).toInt();
    // List<Image> puzzleGalleries2 =
    List.generate(totalRender, (index) {
      Offset offset = Offset((img.width / total) * (index % total),
          (img.width / total) * (index ~/ total));

      // print("object $img - $total - $totalGrid - $offset");
      puzzleImages.add(StaticFunc.getCropImage(img,
          returnDataList: returnDataList,
          offset: offset,
          targetSize: targetSize,
          padding: padding,
          returnImageData: returnImageData,
          size: Size(
              img.width.toDouble() / total,
              (heightSameWidth ? img.width.toDouble() : img.height.toDouble()) /
                  total)));
    });

    return puzzleImages;
  }

  static renderImagePuzzle(img) {
    DataManager.puzzleSources = List<image_plugin.Image>.from(buildCropImages(
            img!, 5,
            returnImageData: true, totalRender: 5, heightSameWidth: true))
        .map((e) {
          PuzzleSource source = PuzzleSource(e, null);
          source.generateImageByte();
          return source;
        })
        .cast<PuzzleSource>()
        .toList();
  }
}

List<int> computeEncode(img) => image_plugin.encodePng(img);
