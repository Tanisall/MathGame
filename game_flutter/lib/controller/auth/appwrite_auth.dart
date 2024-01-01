// ignore_for_file: unused_local_variable

import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:game_flutter/pages/login.dart';
import 'package:game_flutter/pages/startup.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  Client client = Client();
  RxBool isLoading = false.obs;
  var uid = "".obs;
  var username = "".obs;
  late Account account;

  @override
  void onInit() {
    super.onInit();
    account = Account(client);
    client
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('6591d2ab3257f076fa44');
  }

  Future register(String email, String password, String username) async {
    try {
      isLoading.value = true;
      final result = await account.create(
          userId: ID.unique(),
          email: email,
          password: password,
          name: username);

      Get.snackbar('Success', 'Registration successful',
          backgroundColor: Colors.green);
      Get.off(LoginScreen());
    } catch (e) {
      Get.snackbar('Error', 'Registration failed: $e',
          backgroundColor: Colors.red);
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future login(String email, String password) async {
    try {
      isLoading.value = true;
      final result = await account.createEmailSession(
        email: email,
        password: password,
      );

      Get.snackbar('Success', 'Login successful',
          backgroundColor: Colors.green);
      Get.off(() => const StartupPage());
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future logout() async {
    try {
      final result = await account.deleteSessions();
      Get.offAll(() => LoginScreen());
    } catch (e) {
      log(e.toString());
    }
  }

  Future getUserId() async {
    try {
      final result = await account.get();
      uid.value = result.$id;
      return result.$id;
    } catch (e) {
      log(e.toString());
    }
  }

  Future getUsername() async {
    try {
      final result = await account.get();
      username.value = result.name;
      log(result.name.toString());
      return result.name;
    } catch (e) {
      log(e.toString());
    }
  }
}
