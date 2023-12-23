import 'package:flutter/material.dart';
import 'dart:math' as Math;

class MyScaffold extends StatelessWidget {
  Widget body;
  bool enableBack;

  MyScaffold({Key? key, required this.body, this.enableBack = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    double min = Math.min(size.width, size.height);
    double resizeScale = (min > 800 ? 1 : min / 800 * 1);
    var height = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      drawer: Drawer(),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            body,
            if (enableBack)
              Positioned(
                left: 0,
                top: height,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Image.asset(
                      "assets/images/back.png",
                      width: 140 * resizeScale,
                    ),
                    // child: Icon(
                    //   Icons.arrow_back,
                    //   size: 40 * resizeScale,
                    //   color: Colors.white,
                    // ),
                  ),
                ),
              )
          ],
        ),
        top: false,
      ),
    );
  }
}
