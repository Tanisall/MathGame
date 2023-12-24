// ignore_for_file: must_be_immutable, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_flutter/helpers/model.dart';

class StarEffect extends StatefulWidget {
  Widget child;
  StarEffect({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<StarEffect> createState() => _StarEffectState();
}

class _StarEffectState extends State<StarEffect>
    with SingleTickerProviderStateMixin {
  ValueNotifier<List<Star>> starsNotifier = ValueNotifier<List<Star>>([]);
  late AnimationController animControlStar;
  late Animation animStar;
  Size? size;

  @override
  void initState() {
    super.initState();
    animControlStar = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    animStar = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animControlStar, curve: Curves.easeInOutCubicEmphasized));

    animStar.addListener(() {
      starsNotifier.value = starsNotifier.value.map((e) {
        e.setMeter(rate: 0.02);
        return e;
      }).toList();

      starsNotifier.notifyListeners();
      // value = (animStar.value - 0.5) / 0.5 * 1;
      // }
    });

    // animControlStar.addStatusListener((status) {
    //   if (status == AnimationStatus.dismissed) {
    //     animControlStar.repeat();
    //   }
    // });

    // animate(0);
    WidgetsBinding.instance.addPostFrameCallback((_) => generateStars());
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    var height = MediaQuery.of(context).viewPadding.top;
    return Container(
      padding: EdgeInsets.only(top: height),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/images/background_game.jpeg"),
        ),
      ),
      child: ValueListenableBuilder(
        valueListenable: starsNotifier,
        builder: (buildContext, List<Star> stars, child) {
          return Stack(
            children: [
              ...stars
                  .map(
                    (star) => Positioned(
                      left: star.offset.dx * size!.width,
                      top: star.offset.dy * size!.height,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 500),
                        scale: star.scale,
                        // child: AnimatedRotation(
                        //   duration: const Duration(milliseconds: 500),
                        //   turns: star.degree * 2 * pi,
                        child: Opacity(
                          opacity: star.opacity,
                          child: const Icon(Icons.star, color: Colors.white),
                        ),
                        // ),
                      ),
                    ),
                  )
                  .toList(),
              ...[widget.child],
            ],
          );
        },
      ),
    );
  }

  void generateStars() {
    randomStar();
    animControlStar.repeat();
  }

  randomStar() {
    starsNotifier.value.clear();
    starsNotifier.value = List.generate(
      40,
      (index) => Star(
        offset: Offset(Random().nextDouble(), Random().nextDouble()),
        scale: Random().nextDouble() / 1 * 0.9,
        opacity: Random().nextDouble(),
      ),
    ).toList();
  }

  @override
  void dispose() {
    starsNotifier.dispose();
    animControlStar.dispose();
    super.dispose();
  }
}
