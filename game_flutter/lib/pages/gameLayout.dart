// ignore_for_file: library_prefixes, no_leading_underscores_for_local_identifiers, unused_local_variable, avoid_unnecessary_containers, prefer_const_constructors, file_names

import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:confetti/confetti.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:game_flutter/controller/database/firebase_db.dart';
import 'package:game_flutter/singletons/sound_manager.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:game_flutter/generalNotifier.dart';
import 'package:game_flutter/helpers/fontHelper.dart';
import 'package:game_flutter/helpers/gameWidget.dart';
import 'package:game_flutter/helpers/model.dart';
import 'package:game_flutter/helpers/starEffect.dart';
import 'dart:math' as Math;
import 'package:game_flutter/singletons/data_manager.dart';

class GameLayout extends StatefulWidget {
  const GameLayout({Key? key}) : super(key: key);

  @override
  State<GameLayout> createState() => _GameLayoutState();
}

typedef MyCustomBuilder = Widget Function(
  BuildContext context,
  Widget? child,
  dynamic value,
);

class _GameLayoutState extends State<GameLayout>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  final DatabaseController databaseController = Get.put(DatabaseController());

  late GeneralNotifier generalNotifier;
  CarouselController carouselController = CarouselController();

  late Size size;
  late double min;
  late double resizeScale;
  late Axis axis;
  final PageController controller = PageController();
  //memakai game widget1
  GameWidget? gameWidget1;
  GameWidget? gameWidget2;
  GameWidget? gameWidget3;
  GlobalKey<GameWidgetState_> globalKey1 = GlobalKey<GameWidgetState_>();
  GlobalKey<GameWidgetState_> globalKey2 = GlobalKey<GameWidgetState_>();
  GlobalKey<GameWidgetState_> globalKey3 = GlobalKey<GameWidgetState_>();
  CarouselController buttonCarouselController = CarouselController();
  late AnimationController animateCtrlCounter;
  late Animation<double> animation;
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    generalNotifier = Provider.of<GeneralNotifier>(context, listen: false);
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 10));

    // _controllerCenter.addListener(
    //   () {
    //     _controllerCenter.
    //   },
    // );
    initiateAnimations();

    super.initState();
  }

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (Math.pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * Math.cos(step),
          halfWidth + externalRadius * Math.sin(step));
      path.lineTo(
          halfWidth + internalRadius * Math.cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * Math.sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  initiateAnimations() {
    animateCtrlCounter = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    animation = Tween<double>(begin: 0, end: 1).animate(animateCtrlCounter);
  }

  @override
  void dispose() {
    controller.dispose();
    _controllerCenter.dispose();
    // buttonCarouselController.
    globalKey1.currentState?.dispose();
    globalKey2.currentState?.dispose();
    globalKey3.currentState?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Metode untuk memainkan file audio
    // Future<void> _playAudio() async {
    //   await _audioPlayer.play(AssetSource('sounds/xylophone-20462.mp3'),
    //       volume: 1);
    //   await _audioPlayer.setVolume(1);
    //   _audioPlayer.onPlayerComplete.listen((event) {
    //     // Audio selesai, mulai lagi dari awal
    //     _audioPlayer.seek(Duration.zero);
    //     _audioPlayer.play(AssetSource('sounds/xylophone-20462.mp3'), volume: 1);
    //   });
    // }

    size = MediaQuery.of(context).size;

    min = Math.min(size.width - 50, size.height - 50);
    resizeScale = (min > (900 * 0.8) ? 1 : min / (900 * 0.8));
    axis = size.aspectRatio > 1.45 ? Axis.horizontal : Axis.vertical;

    AppBar appBar = appbar();

    SoundManager.moveTile();
    // _playAudio();

// Mulai Game
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: StarEffect(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double heightAppbar = appBar.preferredSize.height;
                  double maxShortest = constraints.biggest.shortestSide;
                  double minSizeSideBox = 350 * resizeScale;

                  Size minSizeSide = axis == Axis.horizontal
                      ? Size(
                          Math.max(constraints.biggest.width - maxShortest,
                              minSizeSideBox),
                          constraints.biggest.height)
                      : Size(
                          constraints.biggest.width,
                          Math.max(constraints.biggest.height - maxShortest,
                              minSizeSideBox));

                  Size sizeMaxGame = Size.square(Math.min(
                      minSizeSide.shortestSide > minSizeSideBox
                          ? maxShortest - 100
                          : maxShortest - minSizeSideBox,
                      500));
                  print("max $maxShortest - $sizeMaxGame - $minSizeSide");

                  setGameWidgets(Size.square(
                      sizeMaxGame.longestSide - (5 * resizeScale) * 2));

                  return Container(
                    padding: const EdgeInsets.all(5),
                    constraints: BoxConstraints.tight(constraints.biggest),
                    margin: EdgeInsets.only(top: heightAppbar),
                    child: getMainMenuNotifier(
                        builder: (context, menuChild, int menuIndex) {
                      return Flex(
                        direction: axis,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: getInfoGameNotifier(builder:
                                (context, childInfo, InfoGame infoGame) {
                              databaseController.move.value = infoGame.move;
                              return Flex(
                                mainAxisAlignment: axis == Axis.horizontal
                                    ? MainAxisAlignment.center
                                    : MainAxisAlignment.end,
                                crossAxisAlignment: axis == Axis.horizontal
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.center,
                                direction: Axis.vertical,
                                children: [
                                  // FontHelper(
                                  //   "${generalNotifier.getMenuIndex} ${constraints.biggest.aspectRatio}",
                                  //   color: Colors.white,
                                  // ),
                                  Flexible(
                                    child: FontHelper(
                                      "${infoGame.title}",
                                      color: Colors.orange,
                                      showStroke: true,
                                      strokePercent: 0.4,
                                      sizeText: 50 * resizeScale,
                                      overflow: TextOverflow.visible,
                                      fontFamily: FontClass.KidZone,
                                    ),
                                  ),
                                  Flexible(
                                    child: FontHelper(
                                      "Bergerak   ${infoGame.move}",
                                      color: Colors.orange,
                                      showStroke: true,
                                      strokePercent: 0.4,
                                      sizeText: 50 * resizeScale,
                                      overflow: TextOverflow.visible,
                                      fontFamily: FontClass.KidZone,
                                    ),
                                  ),
                                  Flexible(
                                    child: FontHelper(
                                      "Tiles   ${infoGame.tiles}",
                                      color: Colors.orange,
                                      showStroke: true,
                                      strokePercent: 0.4,
                                      sizeText: 50 * resizeScale,
                                      overflow: TextOverflow.visible,
                                      fontFamily: FontClass.KidZone,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                          Container(
                            margin: EdgeInsets.all(5 * resizeScale),
                            constraints: BoxConstraints.tight(Size.square(
                                sizeMaxGame.longestSide -
                                    (5 * resizeScale) * 2)),
                            child: Stack(
                              children: [
                                Offstage(
                                  offstage: menuIndex != 0,
                                  // Mulai
                                  child: gameWidget1,
                                ),
                                Offstage(
                                  offstage: menuIndex != 1,
                                  child: gameWidget2,
                                ),
                                Offstage(
                                  offstage: menuIndex != 2,
                                  child: gameWidget3,
                                ),
                                ValueListenableBuilder(
                                  valueListenable:
                                      generalNotifier.counterNotifier,
                                  builder: (context, int value, child) {
                                    String text = "";

                                    if (value == 4) {
                                      text = "Siap!";
                                    } else if (value > 0) {
                                      text = "$value";
                                    } else if (value == 0) {
                                      text = "Mulai!";
                                    }

                                    return Offstage(
                                      offstage: value < 0,
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: double.maxFinite,
                                        height: double.maxFinite,
                                        color: Colors.black54,
                                        child: AnimatedBuilder(
                                          animation: animation,
                                          builder: (context, childAnimated) {
                                            // print("value $value - ${animation.value}");
                                            return Transform.scale(
                                              scale: animation.value,
                                              child: childAnimated,
                                            );
                                          },
                                          child: FontHelper(
                                            text,
                                            sizeText: 150 * resizeScale,
                                            color: Colors.white,
                                            align: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: ConfettiWidget(
                                    confettiController: _controllerCenter,
                                    blastDirectionality: BlastDirectionality
                                        .explosive, // don't specify a direction, blast randomly
                                    shouldLoop:
                                        true, // start again as soon as the animation is finished
                                    colors: const [
                                      Colors.green,
                                      Colors.redAccent,
                                      Colors.pink,
                                      Colors.orange,
                                      Colors.purple
                                    ], // manually specify the colors to be used
                                    createParticlePath:
                                        drawStar, // define a custom shape/path.
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Container(
                              child: Flex(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                direction: axis,
                                children: [
                                  getMainMenuNotifier(
                                      builder: (context, menuChild, menuIndex) {
                                    return AnimatedScale(
                                      scale: menuIndex == 2 ? 1 : 0,
                                      curve: Curves.easeInCirc,
                                      duration: Duration(milliseconds: 300),
                                      child: Transform.rotate(
                                        angle:
                                            (axis == Axis.horizontal ? 90 : 0) *
                                                Math.pi /
                                                180,
                                        child: getActionCntrlNotifier(builder:
                                            (context, childAction, actionCtrl) {
                                          return FlutterSwitch(
                                            value: actionCtrl.name == "rotate",
                                            inactiveColor: Colors.transparent,
                                            activeColor: Colors.transparent,
                                            toggleColor: Color.fromARGB(
                                                255, 186, 149, 250),
                                            toggleBorder: Border.all(
                                                width: 2, color: Colors.white),
                                            switchBorder: Border.all(
                                                width: 2, color: Colors.white),
                                            borderRadius: 50 * resizeScale,
                                            height: 100 * resizeScale,
                                            width: 200 * resizeScale,
                                            toggleSize: 80 * resizeScale,
                                            inactiveIcon: Image.asset(
                                              "assets/images/move.png",
                                              // width: 140 * resizeScale,
                                            ),
                                            activeIcon: Image.asset(
                                              "assets/images/rotate.png",
                                              // width: 140 * resizeScale,
                                            ),
                                            onToggle: (status) {
                                              generalNotifier.setActionNotifier(
                                                  status
                                                      ? ActionControl.rotate
                                                      : ActionControl.move);
                                              setActionCtrl();
                                            },
                                          );
                                        }),
                                      ),
                                    );
                                  })
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  );
                },
              ),
            ),
            Container(
              // height: 50,
              // color: Colors.red,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    padding: EdgeInsets.all(50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        getTotalSplitNotifier(
                            builder: (context, puzzleChild, puzzleIndex) {
                          return InkWell(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: FontHelper(
                                // "Grid\n$puzzleIndex x $puzzleIndex",
                                "Pola",
                                align: TextAlign.center,
                                color: Colors.black,
                                sizeText: 20 * resizeScale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () => onTapGridBtn(),
                          );
                        }),
                        SizedBox(
                          width: 50,
                        ),
                        getMainMenuNotifier(child: getPuzzleIndexNotifier(
                            builder: (context, puzzleChild, puzzleIndex) {
                          return InkWell(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: getPuzzleIndexNotifier(
                                builder: (context, child, value) {
                                  return Container(
                                    child: Image.memory(
                                      DataManager
                                          .puzzleSources![value].imageByte!,
                                      fit: BoxFit.contain,
                                      height: 100 * resizeScale,
                                    ),
                                  );
                                },
                              ),
                            ),
                            onTap: () => onTapImageBtn(),
                          );
                        }), builder: (context, menuChild, menuIndex) {
                          return Offstage(
                            offstage: menuIndex == 0,
                            child: menuChild,
                          );
                        })
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

// DataManager.puzzleSources
  Widget getMainMenuNotifier(
      {required Function(
        BuildContext context,
        Widget? child,
        int value,
      ) builder,
      Widget? child}) {
    return ValueListenableBuilder(
      builder: (context, int mainMenus, childMenu) {
        return builder.call(context, childMenu, mainMenus);
      },
      valueListenable: generalNotifier.mainMenuIndex,
      child: child,
    );
  }

  Widget getPuzzleIndexNotifier(
      {required Function(
        BuildContext context,
        Widget? child,
        int value,
      ) builder,
      Widget? child}) {
    return ValueListenableBuilder(
      builder: (context, int indexMenu, childMenu) {
        return builder.call(context, childMenu, indexMenu);
      },
      valueListenable: generalNotifier.choicePuzzleIndex,
      child: child,
    );
  }

  Widget getActionCntrlNotifier(
      {required Function(
        BuildContext context,
        Widget? child,
        ActionControl value,
      ) builder,
      Widget? child}) {
    return ValueListenableBuilder(
      builder: (context, ActionControl actionControl, childMenu) {
        return builder.call(context, childMenu, actionControl);
      },
      valueListenable: generalNotifier.actionNotifier,
      child: child,
    );
  }

  Widget getInfoGameNotifier(
      {required Function(
        BuildContext context,
        Widget? child,
        InfoGame value,
      ) builder,
      Widget? child}) {
    return ValueListenableBuilder(
      builder: (context, InfoGame value, child) {
        return builder.call(context, child, value);
      },
      valueListenable: generalNotifier.infoGameNotifier,
      child: child,
    );
  }

  Widget getTotalSplitNotifier(
      {required Function(
        BuildContext context,
        Widget? child,
        int value,
      ) builder,
      Widget? child}) {
    return ValueListenableBuilder(
      builder: (context, int value, child) {
        return builder.call(context, child, value);
      },
      valueListenable: generalNotifier.totalSplitNotifier,
      child: child,
    );
  }

  AppBar appbar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      actions: [
        getMainMenuNotifier(builder: (context, child, value) {
          return const Row();
        })
      ],
    );
  }

  void setGameWidgets(sizeMaxGame) {
    if (gameWidget1 != null) {
      globalKey1.currentState!.setUpdate(
        size: sizeMaxGame,
        paddingOuter: resizeScale * 20,
        padding: 4 * resizeScale,
        totalSplit: generalNotifier.getTotalSplit,
      );
    }

    gameWidget1 ??= GameWidget(
      DataManager.puzzleSources![generalNotifier.choicePuzzleIndex.value],
      key: globalKey1,
      size: sizeMaxGame,
      padding: 4 * resizeScale,
      hard: 0,
      // durationPieceMove: Duration(milliseconds: 300),
      totalSplit: 3,
      counterCallback: (int counter) {},
      paddingOuter: resizeScale * 20,
      moveCallback: (totalUnfinishTiles, move) => generalNotifier
          .setInfoGameNotifier(tiles: totalUnfinishTiles, move: move),
      successCallback: () => winFeedback(0),
    );
    gameWidget2 ??= GameWidget(
      DataManager.puzzleSources![generalNotifier.choicePuzzleIndex.value],
      key: globalKey2,
      size: sizeMaxGame,
      hard: 1,
      padding: 4 * resizeScale,
      // durationPieceMove: Duration(milliseconds: 300),
      totalSplit: 3,
      counterCallback: (int counter) {
        if (generalNotifier.getMenuIndex != 1) {
          return;
        }
        generalNotifier.setCounterNotifier(counter);
        animateCtrlCounter.reset();
        animateCtrlCounter.forward();
      },
      // circleShape: true,
      paddingOuter: resizeScale * 20,
      successCallback: () => winFeedback(),
      moveCallback: (totalUnfinishTiles, move) => generalNotifier
          .setInfoGameNotifier(tiles: totalUnfinishTiles, move: move),
    );
    gameWidget3 ??= GameWidget(
      DataManager.puzzleSources![generalNotifier.choicePuzzleIndex.value],
      key: globalKey3,
      size: sizeMaxGame,
      padding: 4 * resizeScale,
      hard: 2,
      // durationPieceMove: Duration(milliseconds: 300),
      totalSplit: 3,
      counterCallback: (int counter) {
        if (generalNotifier.getMenuIndex != 2) {
          return;
        }
        generalNotifier.setCounterNotifier(counter);
        animateCtrlCounter.reset();
        animateCtrlCounter.forward();
      },
      paddingOuter: resizeScale * 30,
      successCallback: () => winFeedback(),
      moveCallback: (totalUnfinishTiles, move) => generalNotifier
          .setInfoGameNotifier(tiles: totalUnfinishTiles, move: move),
    );
  }

  void setActionCtrl() {
    if (generalNotifier.getMenuIndex == 2) {
      globalKey3.currentState?.changeAction(generalNotifier.getActionCtrl);
    }
  }

  onTapGridBtn() {
    var dialog = showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        Size sizeModal = MediaQuery.of(context).size;

        return Center(
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(0 * resizeScale),
            color: Colors.white,
            constraints: BoxConstraints.tight(
                Size.square(Math.min(sizeModal.shortestSide, 550))),
            child: getTotalSplitNotifier(
              builder: (context, child, value) {
                // untuk kotak kotak
                return GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (buildContext, index) {
                    databaseController.pola.value =
                        "${(index + 3)}x${(index + 3)}";

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          generalNotifier.setTotalSplit((index + 3));

                          generalNotifier.setCounterNotifier(-1);
                          generalNotifier.setInfoGameNotifier(
                              title: "Math Puzzle!", move: 0, tiles: 0);
                          animateCtrlCounter.reset();

                          globalKey1.currentState!.updateTotalSplit(index + 3);
                          globalKey2.currentState!.updateTotalSplit(index + 3);
                          globalKey3.currentState!.updateTotalSplit(index + 3);
                          if (generalNotifier.getMenuIndex == 0) {
                            // Pola 3x3
                            globalKey1.currentState?.initiateGame(false);
                            globalKey1.currentState?.randomPuzzle();
                          } else if (generalNotifier.getMenuIndex == 1) {
                            // globalKey2.currentState!
                            //     .updateTotalSplit(index + 3);

                            globalKey2.currentState?.initiateGame(false);
                          } else if (generalNotifier.getMenuIndex == 2) {
                            // globalKey3.currentState!
                            //     .updateTotalSplit(index + 3);

                            globalKey3.currentState?.initiateGame(false);
                          }
                        },
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 500),
                          scale: value == (index + 3) ? .9 : 0.7,
                          child: Container(
                            margin: EdgeInsets.all(20 * resizeScale),
                            // color: Colors.red,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    // color: Colors.red,
                                    child: GridView.builder(
                                      scrollDirection: Axis.horizontal,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: (index + 3),
                                        childAspectRatio: 1,
                                        crossAxisSpacing: 1,
                                        mainAxisSpacing: 1,
                                      ),
                                      shrinkWrap: true,
                                      physics: ScrollPhysics(),
                                      itemCount: Math.pow(index + 3, 2).toInt(),
                                      itemBuilder: (buildContext, index2) {
                                        return Container(
                                          color: Colors.blueAccent,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                FontHelper(
                                  "${(index + 3)}x${(index + 3)}",
                                  sizeText: 50 * resizeScale,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  onTapImageBtn() {
    var dialog = showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        Size sizeModal = MediaQuery.of(context).size;

        return Center(
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(40 * resizeScale),
            color: Colors.white,
            constraints: BoxConstraints.tight(
                Size.square(Math.min(sizeModal.shortestSide, 550))),
            child: getPuzzleIndexNotifier(
              builder: (context, child, value) {
                return GridView.builder(
                  scrollDirection: Axis.vertical,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: DataManager.puzzleSources!.length,
                  itemBuilder: (buildContext, index) {
                    PuzzleSource puzzleSource =
                        DataManager.puzzleSources![index];

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          generalNotifier.setChoicePuzzleIndex(index);

                          // generalNotifier.setCounterNotifier(-1);
                          // generalNotifier.setInfoGameNotifier(
                          //     title: "Puzzle Challenge!", move: 0, tiles: 0);
                          // animateCtrlCounter.reset();

                          if (generalNotifier.getMenuIndex == 1) {
                            globalKey2.currentState!
                                .updatePuzzleSource(puzzleSource);

                            // globalKey3.currentState?.initiateGame(false);
                          } else if (generalNotifier.getMenuIndex == 2) {
                            globalKey3.currentState!
                                .updatePuzzleSource(puzzleSource);

                            // globalKey3.currentState?.initiateGame(false);
                          }
                        },
                        child: AnimatedScale(
                          duration: Duration(milliseconds: 500),
                          scale: value == index ? .9 : 0.7,
                          child: Image.memory(puzzleSource.imageByte!),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  winFeedback([int type = 1]) {
    generalNotifier.setInfoGameNotifier(title: "Menang!");
    databaseController.storeData(
        databaseController.move.value, databaseController.pola.value);
    _controllerCenter.play();
    Timer timer = Timer(
      Duration(seconds: 3),
      () {
        if (type == 0) {
          generalNotifier.setCounterNotifier(-1);
          generalNotifier.setInfoGameNotifier(
              title: "Math Puzzle!", move: 0, tiles: 0);
          animateCtrlCounter.reset();
          globalKey1.currentState!.randomPuzzle();
          globalKey1.currentState?.initiateGame(false);
        }
        _controllerCenter.stop();
      },
    );
  }
}
