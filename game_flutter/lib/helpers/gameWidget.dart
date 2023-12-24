// ignore_for_file: library_prefixes, must_be_immutable, camel_case_types, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:game_flutter/generalNotifier.dart';
import 'dart:math' as Math;

import 'package:game_flutter/helpers/model.dart';
import 'package:game_flutter/singletons/sound_manager.dart';
import 'package:game_flutter/statics/function.dart';

class GameWidget extends StatefulWidget {
  PuzzleSource puzzleSource;
  int totalSplit;
  int hard;
  double padding;
  double? paddingOuter;
  Duration? durationPieceMove;
  bool? circleShape;
  Size size;

  Function()? successCallback;
  Function(int)? counterCallback;
  Function(int totalWrongTileCount, int move)? moveCallback;
  GameWidget(this.puzzleSource,
      {Key? key,
      required this.size,
      this.hard = 0,
      this.successCallback,
      this.totalSplit = 3,
      this.padding = 0,
      this.durationPieceMove,
      this.counterCallback,
      this.paddingOuter,
      this.moveCallback,
      this.circleShape = false})
      : super(key: key) {
    paddingOuter ??= 0;
    durationPieceMove ??= const Duration(milliseconds: 500);
  }

  @override
  State<GameWidget> createState() => GameWidgetState_();
}

class GameWidgetState_ extends State<GameWidget> {
  Widget? image;
  ValueNotifier<List<Box>> puzzlesNotifier = ValueNotifier<List<Box>>([]);
  ValueNotifier<ActionControl> actionNotifier =
      ValueNotifier<ActionControl>(ActionControl.move);
  ValueNotifier<GameStatus> gameStatusNotifier =
      ValueNotifier<GameStatus>(GameStatus.start);
  late GeneralNotifier generalNotifier;

  final AudioPlayer _audioPlayer = AudioPlayer();

  List<dynamic>? images;
  Timer? timer;

  // generateStars();
  late Size size;
  late Size minSize;
  late Size maxSize;
  late Size sizePerBlok;
  late double min;
  late double minOuter;
  late double max;
  late double resizeScale;
  late double paddingOutCalc = 0;
  late double borderRadius = 10;
  int splitOld = 0;
  Stopwatch stopwatch = Stopwatch();

  @override
  void dispose() {
    puzzlesNotifier.dispose();
    actionNotifier.dispose();
    gameStatusNotifier.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    generalNotifier = Provider.of<GeneralNotifier>(context, listen: false);
    print("widget ${widget.paddingOuter}");

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initiateGame());
  }

  @override
  Widget build(BuildContext context) {
    size = widget.size;
    // size = Size(size.width, size.height);

    updateData();
    // updateViews();
    return ValueListenableBuilder(
      valueListenable: gameStatusNotifier,
      builder: (context, GameStatus gameStatus, child) {
        return InkWell(
          onTap: !(widget.hard != 0 &&
                  showImage(
                      gameStatus, [GameStatus.complete, GameStatus.start]))
              ? null
              : () => startGame(),
          child: Container(
            width: minOuter,
            height: minOuter,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                color: Colors.white,
                image: widget.hard == 0
                    ? null
                    : DecorationImage(
                        image:
                            Image.memory(widget.puzzleSource.imageByte!).image,
                        fit: BoxFit.cover)),
            padding: EdgeInsets.all(paddingOutCalc),
            alignment: Alignment.center,
            child: AnimatedOpacity(
              opacity:
                  showImage(gameStatus, [GameStatus.complete, GameStatus.start])
                      ? 0
                      : 1,
              duration: Duration(milliseconds: 300),
              curve: Curves.ease,
              child: puzzleLayout(gameStatus),
            ),
          ),
        );
      },
    );
  }

  Widget getMainMenuNotifier(
      {required Function(
        BuildContext context,
        Widget? child,
        int value,
      ) builder,
      Widget? child}) {
    return ValueListenableBuilder(
      child: child,
      builder: (context, int mainMenuIndex, childMenu) {
        return builder.call(context, childMenu, mainMenuIndex);
      },
      valueListenable: generalNotifier.mainMenuIndex,
    );
  }

  initiateGame([bool startup = true]) {
    timer?.cancel();

    setGameStatus(GameStatus.start);

    double ratio = widget.puzzleSource.image!.width.toDouble() /
        (minOuter + widget.padding * 2);

    // size = MediaQuery.of(context).size;
    // min = Math.min(size.width, size.height);
    // resizeScale = (min > 800 ? 1 : min / 800 * 1);
    if (startup) {
      image = StaticFunc.getCropImage(
        widget.puzzleSource.image!,
        offset: Offset((paddingOutCalc + widget.padding) * ratio,
            (paddingOutCalc + widget.padding) * ratio),
        size: Size.square((min) * ratio),
        // targetSize: Size.square(min),
        // size: Size.square(min),
      );
    }
    // image = StaticFunc.exportImageWidget(widget.puzzleSource.image!);

    if (splitOld != widget.totalSplit || startup) {
      if (widget.hard != 0) {
        var imageTemp = widget.paddingOuter == 0
            ? widget.puzzleSource.image!
            : StaticFunc.getCropImage(
                widget.puzzleSource.image!,
                offset: Offset((paddingOutCalc + widget.padding) * ratio,
                    (paddingOutCalc + widget.padding) * ratio),
                size: Size.square((min) * ratio),
                returnImageData: true,
              );

        images = List<Image>.from(StaticFunc.buildCropImages(
          imageTemp,
          widget.totalSplit,
          // targetSize: Size((min / widget.totalSplit), (min / widget.totalSplit)),
          padding: widget.padding,
        ));
      } else {
        images = List.generate(
            Math.pow(widget.totalSplit, 2).toInt(), (index) => null);
      }

      splitOld = widget.totalSplit;
    }

    generatePuzzle();
    if (generalNotifier.getMenuIndex == 0) {
      randomPuzzle();

      setGameStatus(GameStatus.playing);
    }
    // setState(() {});
  }

  void startGame() {
    setGameStatus(GameStatus.random);
    widget.counterCallback?.call(4);

    int count = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer value) {
      count += 1;

      if (count <= 3) {
        // randomPuzzle(true);
        widget.counterCallback?.call(4 - count);
        Future.delayed(const Duration(milliseconds: 500))
            .then((value) => randomPuzzle());
      } else {
        value.cancel();
        widget.counterCallback?.call(0);
        setGameStatus(GameStatus.playing);
        stopwatch.start();
        Future.delayed(const Duration(seconds: 1))
            .then((value) => widget.counterCallback?.call(-1));
      }
    });
  }

  Future<void> restartGame() async {
    stopwatch.reset();
    setGameStatus(GameStatus.random);
    generatePuzzle();
    await Future.delayed(const Duration(seconds: 1));

    randomPuzzle();
    Timer timer = Timer.periodic(const Duration(seconds: 1), (value) {
      randomPuzzle();
    });

    Future.delayed(const Duration(seconds: 3)).then((value) {
      timer.cancel();
      setGameStatus(GameStatus.playing);
    });
  }

  void setGameStatus(GameStatus gameStatus) {
    gameStatusNotifier.value = gameStatus;
    gameStatusNotifier.notifyListeners();
  }

  void generatePuzzle() {
    puzzlesNotifier.value = images!.asMap().entries.map((mapper) {
      Box box = Box(indexCorrect: mapper.key);
      box.setImg(mapper.value);
      box.generateOffset(widget.totalSplit, min);
      box.setSize(sizePerBlok);

      return box;
    }).toList();

    puzzlesNotifier.value.last.setEmpty(true);
    puzzlesNotifier.notifyListeners();
  }

  void randomPuzzle([bool center = false]) {
    if (center) {
      puzzlesNotifier.value = puzzlesNotifier.value.map((e) {
        e.setOffset(Offset.zero.translate((min / 2 - sizePerBlok.width / 2),
            (min / 2 - sizePerBlok.height / 2)));
        return e;
      }).toList();
      puzzlesNotifier.notifyListeners();
      return;
    }

    for (var i = 0; i < 20; i++) {
      Box emptyBox = puzzlesNotifier.value.firstWhere((box) => box.isEmpty);
      Axis axis = i % 2 == 0 ? Axis.horizontal : Axis.vertical;
      List<int> totalKey = getLinePuzzle(axis, emptyBox.index)
          .where((element) => element != emptyBox.index)
          .toList();

      int randomKey = totalKey[Math.Random().nextInt(totalKey.length)];

      moveLinePuzzle(axis, emptyBox.index, randomKey, totalKey);
    }

    if (widget.hard == 2) {
      puzzlesNotifier.value = puzzlesNotifier.value.map((e) {
        e.randomRotate();
        return e;
      }).toList();
    }

    puzzlesNotifier.notifyListeners();

    widget.moveCallback?.call(
        puzzlesNotifier.value
            .where((element) => !element.isCorrect() && !element.isEmpty)
            .length,
        0);
  }

  touchBox(int key, ActionControl action) async {
    // disini sound
    if (action == ActionControl.move) {
      Box emptyBox = puzzlesNotifier.value.firstWhere((box) => box.isEmpty);
      // now allowed if touch is not in line with empty box
      if (!emptyBox.isSameLine(key, widget.totalSplit)) return;

      int keyEmpty = emptyBox.index;

      Axis axis = key ~/ widget.totalSplit == keyEmpty ~/ widget.totalSplit
          ? Axis.horizontal
          : Axis.vertical;
      moveLinePuzzle(axis, keyEmpty, key, null);
    } else {
      rotatePuzzleBox(key);
    }

    widget.moveCallback?.call(
        puzzlesNotifier.value
            .where((element) => !element.isCorrect() && !element.isEmpty)
            .length,
        1);

    SoundManager.moveTile();
    await _audioPlayer.play(AssetSource('sounds/pop-up-something-160353.wav'));
    await _audioPlayer.setVolume(1);
    puzzlesNotifier.notifyListeners();

    // check current puzzle solve or not
    if (success()) {
      await Future.delayed(Duration(
              milliseconds: widget.durationPieceMove!.inMilliseconds + 0))
          .then((value) async {
        setGameStatus(GameStatus.complete);
        gameStatusNotifier.notifyListeners();
        SoundManager.playSuccess();
        widget.successCallback?.call();
      });
    }
  }

  bool showImage(GameStatus gameStatus, List<GameStatus> list) =>
      list.where((element) => element == gameStatus).isNotEmpty;

  bool success() =>
      puzzlesNotifier.value.where((puzzle) => !puzzle.isCorrect()).isEmpty ||
      showImage(
          gameStatusNotifier.value, [GameStatus.complete, GameStatus.start]);

  List<int> getLinePuzzle(Axis axis, int keyEmpty) {
    List<int> rows = List.generate(widget.totalSplit,
        (index) => (keyEmpty ~/ widget.totalSplit * widget.totalSplit) + index);
    List<int> cols = List.generate(widget.totalSplit,
        (index) => (keyEmpty % widget.totalSplit) + index * widget.totalSplit);

    return axis == Axis.horizontal ? rows : cols;
  }

  void moveLinePuzzle(
      Axis axis, int keyEmpty, int keyDown, List<int>? totalKey) {
    Box emptyBox = puzzlesNotifier.value.firstWhere((box) => box.isEmpty);

    totalKey ??= getLinePuzzle(axis, keyEmpty);

    totalKey.removeWhere((element) =>
        element < Math.min(keyEmpty, keyDown) ||
        element > Math.max(keyEmpty, keyDown));

    List<Box> puzzleBox = puzzlesNotifier.value
        .where((puzzle) => totalKey!.contains(puzzle.index))
        .toList();

    for (var puzzleBox in puzzleBox) {
      puzzleBox.moveIndex(
          keyEmpty < keyDown ? -1 : 1, keyDown, axis, widget.totalSplit);
      puzzleBox.generateOffset(widget.totalSplit, min);
    }

    emptyBox.setIndex(keyDown);
    emptyBox.generateOffset(widget.totalSplit, min);
  }

  void rotatePuzzleBox(int key) {
    puzzlesNotifier.value.firstWhere((box) => box.index == key).rotateBoxTurn();
  }

  void updateData() {
    minOuter = Math.min(widget.size.width, widget.size.height);

    if (widget.circleShape == true) {
      paddingOutCalc =
          ((minOuter - ((minOuter / 2) * Math.cos(Math.pi / 180 * 45)) * 2) /
                  2) +
              widget.paddingOuter!;
    } else {
      paddingOutCalc = widget.paddingOuter!;
    }

    min = minOuter - paddingOutCalc * 2;
    maxSize = MediaQuery.of(context).size;
    max = Math.max(maxSize.width, maxSize.height);
    sizePerBlok = Size((min / widget.totalSplit), (min / widget.totalSplit));
    resizeScale = (min > 800 ? 1 : min / 800 * 1);

    updateViews();
  }

  void updateViews() {
    calculateParams();
    puzzlesNotifier.value = puzzlesNotifier.value.asMap().entries.map((entry) {
      entry.value.generateOffset(widget.totalSplit, min);
      entry.value.setSize(sizePerBlok);
      return entry.value;
    }).toList();
    puzzlesNotifier.notifyListeners();
  }

  changeAction(ActionControl actionControl) async {
    actionNotifier.value = actionControl;
    actionNotifier.notifyListeners();
  }

  updateTotalSplit(totalSplit) {
    if (totalSplit == widget.totalSplit) return;
    widget.totalSplit = totalSplit;
    updateData();
    initiateGame();
    // setState(() {});
  }

  void updatePuzzleSource(PuzzleSource puzzleSource) {
    widget.puzzleSource = puzzleSource;
    initiateGame();
    setState(() {});
  }

  void calculateParams() {}

  puzzleLayout(gameStatus) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 90, 149, 238),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ValueListenableBuilder(
        valueListenable: puzzlesNotifier,
        builder: (context, List<Box> boxes, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              if (boxes.isNotEmpty && gameStatus != GameStatus.start)
                ...boxes
                    .map(
                      (box) => AnimatedPositioned(
                        duration: widget.durationPieceMove!,
                        curve: Curves.ease,
                        left: box.offset.dx,
                        top: box.offset.dy,
                        child: Container(
                          padding: EdgeInsets.all(widget.padding),
                          // color: Colors.red,
                          alignment: Alignment.center,
                          width: box.size!.width,
                          height: box.size!.height,
                          child: box.isEmpty
                              ? Container(
                                  color: Colors.transparent,
                                )
                              : ValueListenableBuilder(
                                  valueListenable: actionNotifier,
                                  builder:
                                      (context, ActionControl action, child) {
                                    return InkWell(
                                      onTap: gameStatus != GameStatus.playing
                                          ? null
                                          : () => touchBox(box.index, action),
                                      child: RotatedBox(
                                        quarterTurns:
                                            generalNotifier.getMenuIndex == 2
                                                ? box.quarterTurn
                                                : 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      borderRadius)),
                                          clipBehavior: Clip.antiAlias,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              // puzzle.img!,
                                              if (box.img != null &&
                                                  widget.hard != 0) ...[
                                                box.img!
                                              ],
                                              if (widget.hard == 0)
                                                Center(
                                                  child: Text(
                                                    "${box.indexCorrect + 1}",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          50 * resizeScale,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    )
                    .toList(),
            ],
          );
        },
      ),
    );
  }

  void setUpdate(
      {Size? size,
      double? padding,
      int? totalSplit,
      int? hard,
      double? paddingOuter}) {
    widget.size = size ??= widget.size;
    widget.totalSplit = totalSplit ??= widget.totalSplit;
    widget.padding = padding ??= widget.padding;
    widget.paddingOuter = paddingOuter ??= widget.paddingOuter;
    widget.hard = hard ??= widget.hard;
    updateData();
    updateViews();

    setState(() {});
  }
}
