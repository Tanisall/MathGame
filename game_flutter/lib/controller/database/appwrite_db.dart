// ignore_for_file: unused_local_variable

import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:game_flutter/model/Score.dart';
import 'package:get/get.dart';

class DatabaseController extends GetxController {
  Client client = Client();
  late Databases databases;
  final dbId = '6591d6cd5400971051a3';
  final scoreCollectionId = '6591d6e9c9d8de2d075b';

  RxList scoreData = [].obs;
  var isLoading = false.obs;
  var move = 0.obs;
  var pola = "3x3".obs;

  @override
  void onInit() {
    super.onInit();
    client
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('6591d2ab3257f076fa44');
    databases = Databases(client);
  }

  Future createDataScore(String docId) async {
    var newData = {};

    try {
      final result = await databases.createDocument(
        databaseId: dbId,
        collectionId: scoreCollectionId,
        documentId: docId,
        data: {"pola": pola.value, "score": move.value},
      );

      move.value = 0;
      pola.value = "3x3";
    } catch (e) {
      log("error at createDataScore() $e");
    }
  }

  Future readDataScore(Future docId) async {
    var id = await docId;
    scoreData.clear();

    try {
      final result = await databases.getDocument(
        databaseId: dbId,
        collectionId: scoreCollectionId,
        documentId: id,
      );

      Score score = Score.fromJson(result.data);
      scoreData.add(score);
    } catch (e) {
      log("error at readDataScore() $e");
    }
  }

  Future updateDataScore(String docId) async {
    try {
      Future result = databases.updateDocument(
          databaseId: dbId,
          collectionId: scoreCollectionId,
          documentId: docId,
          data: {"pola": pola.value, "score": move.value});
    } catch (e) {
      log("error at updateDataScore() $e");
    }
  }

  Future checkDataScore(String docId) async {
    try {
      final result = await databases.getDocument(
        databaseId: dbId,
        collectionId: scoreCollectionId,
        documentId: docId,
      );

      if (result.data.isEmpty) {
        createDataScore(docId);
      } else {
        updateDataScore(docId);
      }
    } catch (e) {
      log("error at checkDataScore() $e");
    }
  }
}
