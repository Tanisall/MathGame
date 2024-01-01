import 'package:flutter/cupertino.dart';
import 'package:game_flutter/helpers/model.dart';

class GeneralNotifier with ChangeNotifier {
  ValueNotifier<int> choicePuzzleIndex = ValueNotifier<int>(0);
  List<MainMenu> mainMenus = List<MainMenu>.from([
    MainMenu(0, "Mudah"),
    MainMenu(1, "Sedang"),
    MainMenu(2, "Sulit"),
  ]);
  ValueNotifier<ActionControl> actionNotifier =
      ValueNotifier<ActionControl>(ActionControl.move);

  ValueNotifier<int> mainMenuIndex = ValueNotifier<int>(0);
  ValueNotifier<int> counterNotifier = ValueNotifier<int>(-1);
  ValueNotifier<InfoGame> infoGameNotifier =
      ValueNotifier<InfoGame>(InfoGame());
  ValueNotifier<int> sourceIndexNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> totalSplitNotifier = ValueNotifier<int>(3);

  void setChoicePuzzleIndex(int choicePuzzleIndex) {
    this.choicePuzzleIndex.value = choicePuzzleIndex;
    this.choicePuzzleIndex.notifyListeners();
  }

  void setMenuIndex(int mainMenuIndex) {
    this.mainMenuIndex.value = mainMenuIndex;
    this.mainMenuIndex.notifyListeners();
  }

  void setActionNotifier(ActionControl action) {
    actionNotifier.value = action;
    actionNotifier.notifyListeners();
  }

  void setCounterNotifier(int counter) {
    counterNotifier.value = counter;
    counterNotifier.notifyListeners();
  }

  void setSourceIndex(int index) {
    sourceIndexNotifier.value = index;
    sourceIndexNotifier.notifyListeners();
  }

  void setTotalSplit(int totalSplit) {
    totalSplitNotifier.value = totalSplit;
    totalSplitNotifier.notifyListeners();
  }

  void setInfoGameNotifier({
    String? title,
    int? tiles,
    int? move,
  }) {
    infoGameNotifier.value.updateData(tiles: tiles, title: title, move: move);
    infoGameNotifier.notifyListeners();
  }

  getChoicePuzzleIndex() => choicePuzzleIndex.value;
  get getMenuIndex => mainMenuIndex.value;
  get getActionCtrl => actionNotifier.value;
  get getCounter => counterNotifier.value;
  get getInfoGame => infoGameNotifier.value;
  get getSourceIndex => sourceIndexNotifier.value;
  get getTotalSplit => totalSplitNotifier.value;
}
