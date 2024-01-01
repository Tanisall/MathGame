import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_flutter/controller/auth/firebase_auth.dart';
import 'package:game_flutter/model/Score.dart';
import 'package:get/get.dart';

class DatabaseController extends GetxController {
  final AuthController authController = Get.put(AuthController());
  RxList scoreData = [].obs;
  var isLoading = false.obs;
  var move = 0.obs;
  var pola = "3x3".obs;

  Future<void> storeData(int score, String pola) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('Score')
          .where('owner', isEqualTo: authController.getUserId())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await updateData(querySnapshot.docs[0].id, score, pola);
      } else {
        await createData(score, pola);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> createData(int score, String pola) async {
    try {
      await FirebaseFirestore.instance.collection('Score').add({
        'owner': authController.getUserId(),
        'score': score,
        'pola': pola,
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> updateData(String documentId, int score, String pola) async {
    try {
      await FirebaseFirestore.instance
          .collection('Score')
          .doc(documentId)
          .update({
        'score': score,
        'pola': pola,
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> readData() async {
    isLoading.value = true;
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Score').get();

      querySnapshot.docs.forEach((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        Score score = Score.fromJson(data);
        scoreData.add(score);
      });

      isLoading.value = false;
    } catch (e) {
      log("Error reading data: $e");
      isLoading.value = false;
    }
  }
}
