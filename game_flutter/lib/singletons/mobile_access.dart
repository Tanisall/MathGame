import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:game_flutter/helpers/myNavigator.dart';
import 'package:game_flutter/statics/function.dart';

String type = "mobile";
// class PlatformMobile {
//   static loadImage(pngBytes) async {
//     var img = await loadImage("images/puzzle-images.png");
//     var byteData = await img.toByteData(format: ImageByteFormat.rawUnmodified);
//     var pngBytes = byteData!.buffer.asUint8List();
//     return decodeImage(pngBytes);
//   }

//   static decodeImage(Uint8List pngBytes) => image.decodeImage(pngBytes);
// }
// The background
SendPort? uiSendPort;
final ReceivePort port = ReceivePort();

Future<image.Image?> renderImage(assetPath, {Size? size}) async {
  var img = await loadImage(assetPath, size);

  var byteData = await img.toByteData(format: ImageByteFormat.png);
  var pngBytes = byteData!.buffer.asUint8List();
  var data = await compute(decodeImage, pngBytes);
  // var data = await Isolate.spawn(decodeImage, pngBytes);
  return data;
}

decodeImage(Uint8List pngBytes) => image.decodeImage(pngBytes);

Future<ui.Image> loadImage(imageString, Size? size) async {
  // Image(image: AssetImage(imageString)).
  ByteData bd = await rootBundle.load(imageString);
  // ByteData bd = await rootBundle.load("graphics/bar-1920×1080.jpg");
  final Uint8List bytes = Uint8List.view(bd.buffer);
  final ui.Codec? codec;
  if (size != null) {
    codec = await instantiateImageCodec(bytes,
        targetHeight: size.height.floor(), targetWidth: size.width.floor());
  } else {
    codec = await instantiateImageCodec(bytes);
  }

  final ui.Image image = (await codec.getNextFrame()).image;

  return image;
  // setState(() => imageStateVarible = image);
}

cropPuzzle(img, context, Widget target) {
  IsolateNameServer.removePortNameMapping("fcmBackground");
  bool stat = IsolateNameServer.registerPortWithName(
    port.sendPort,
    "fcmBackground",
  );

  if (stat) {
    port.listen((_) async {
      StaticFunc.renderImagePuzzle(img);
      await Future.delayed(const Duration(seconds: 1)).then((value2) {
        MyNavigator.pushReplacement(context, target);
      });
    });

    SendPort? uiSendPort = IsolateNameServer.lookupPortByName("fcmBackground");
    uiSendPort?.send(true);
  }
}
    
    


    
    // uiSendPort ??= IsolateNameServer.lookupPortByName("fcmBackground");
    // uiSendPort?.send(true);