import 'dart:html' as html;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;
import 'package:game_flutter/helpers/myNavigator.dart';
import 'package:game_flutter/statics/function.dart';

String type = "web";

Future<image.Image?> renderImage(assetPath, {Size? size}) async {
  html.ImageElement? myImageElement =
      html.ImageElement(src: "assets/" + assetPath);

  size ??=
      Size(myImageElement.width!.toDouble(), myImageElement.height!.toDouble());
  await myImageElement.onLoad.first;
  // allow time for browser to render
  html.CanvasElement myCanvas = html.CanvasElement(
      width: myImageElement.width, height: myImageElement.height);
  html.CanvasRenderingContext2D ctx = myCanvas.context2D;
  ctx.drawImageScaled(
      myImageElement, 0, 0, size.width.floor(), size.height.floor());
  html.ImageData rgbaData =
      ctx.getImageData(0, 0, size.width.floor(), size.height.floor());
  var myImage =
      image.Image.fromBytes(rgbaData.width, rgbaData.height, rgbaData.data);

  return myImage;
}

cropPuzzle(img, context, Widget target) async {
  await compute(renderImageCompute, img).then((value1) async {
    await Future.delayed(const Duration(seconds: 1)).then((value2) {
      // print("gerak");
      MyNavigator.pushReplacement(context, target);
    });
  });
}

renderImageCompute(img) {
  StaticFunc.renderImagePuzzle(img);
}
