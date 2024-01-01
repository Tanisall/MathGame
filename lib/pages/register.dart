// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:game_flutter/controller/auth/firebase_auth.dart';
import 'package:game_flutter/controller/database/firebase_db.dart';
import 'package:game_flutter/pages/login.dart';
import 'package:get/get.dart';
import 'dart:math' as Math;

class RegisterScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final DatabaseController databaseController = Get.put(DatabaseController());

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double min = Math.min(size.width, size.height);
    double resizeScale = (min > 800 ? 1 : min / 800 * 1);
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/icon_math.png",
              width: 250 * resizeScale,
              colorBlendMode: BlendMode.color,
              filterQuality: FilterQuality.high,
            ),
            SizedBox(height: 50),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                authController.registerUser(
                    emailController.text, passwordController.text);
              },
              child: Container(
                height: 60,
                width: size.width,
                decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(16)),
                child: Center(
                    child: Text(
                  "Register",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                )),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            InkWell(
              onTap: () => Get.to(() => LoginScreen()),
              child: Text(
                "Sudah punya akun? Login",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
