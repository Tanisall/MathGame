// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_prefixes

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:game_flutter/controller/auth/firebase_auth.dart';
import 'package:game_flutter/controller/database/firebase_db.dart';
import 'package:game_flutter/helpers/fontHelper.dart';
import 'package:game_flutter/pages/gameLayout.dart';
import 'package:get/get.dart';
import 'dart:math' as Math;

class MainMenuPage extends StatelessWidget {
  final DatabaseController databaseController = Get.put(DatabaseController());
  final AuthController authController = Get.put(AuthController());

  MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    databaseController.readData();

    double min = Math.min(size.width, size.height);
    double resizeScale = (min > 800 ? 1 : min / 800 * 1);
    // GameLayout gameLayout = GameLayout();
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FontHelper(
            "Latest Score",
            color: Color.fromARGB(255, 247, 119, 0),
            sizeText: 50 * resizeScale,
            fontFamily: FontClass.Random,
            strokeColor: Color.fromARGB(255, 255, 255, 255),
            shadowColor: const Color.fromARGB(255, 0, 0, 0),
            shadowOffset: const Offset(0, 1),
            showStroke: true,
            align: TextAlign.center,
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() {
                if (databaseController.isLoading.isTrue) {
                  return Text(
                    "",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                } else {
                  return Text(
                    databaseController.scoreData.isEmpty
                        ? ""
                        : "Pola ${databaseController.scoreData[0].pola} : ",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                }
              }),
              Obx(() {
                if (databaseController.isLoading.isTrue) {
                  return Text(
                    "0 Move",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                } else {
                  return Text(
                    databaseController.scoreData.isEmpty
                        ? ""
                        : "${databaseController.scoreData[0].score} Moves",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                }
              })
            ],
          ),
          SizedBox(
            height: 24,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 50), backgroundColor: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GameLayout()),
              );
            },
            child: Text(
              "Start",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 50), backgroundColor: Colors.white),
            onPressed: () {
              databaseController.scoreData.clear();
              databaseController.readData();
            },
            child: Text(
              "Reload",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 50), backgroundColor: Colors.white),
            onPressed: () {
              authController.logout();
            },
            child: Text(
              "Logout",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          )
        ],
      )),
    );
  }
}

// Define the MainMenu class
class MainMenu {
  final int id;
  final String label;

  MainMenu(this.id, this.label);
}
