import 'package:flutter/material.dart';
import 'package:game_flutter/pages/gameLayout.dart';

class MainMenuPage extends StatelessWidget {
  // List of MainMenu objects
  final List<MainMenu> mainMenus = List<MainMenu>.from([
    MainMenu(0, "Start"),
  ]);

  @override
  Widget build(BuildContext context) {
    // GameLayout gameLayout = GameLayout();
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: mainMenus.map((menu) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(150, 50), backgroundColor: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameLayout()),
                );
              },
              child: Text(
                menu.label,
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Define the MainMenu class
class MainMenu {
  final int id;
  final String label;

  MainMenu(this.id, this.label);
}
