// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:game_flutter/controller/auth/appwrite_auth.dart';
import 'package:game_flutter/controller/database/appwrite_db.dart';
import 'package:game_flutter/pages/register.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final DatabaseController databaseController = Get.put(DatabaseController());

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/icon_math.png",
              width: 150,
              colorBlendMode: BlendMode.color,
              filterQuality: FilterQuality.high,
            ),
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
                authController.login(
                    emailController.text, passwordController.text);
                authController.getUserId();
              },
              child: Container(
                height: 60,
                width: size.width,
                decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(16)),
                child: Center(child: Obx(() {
                  if (authController.isLoading.value == true) {
                    return CircularProgressIndicator(
                      color: Colors.white,
                    );
                  } else {
                    return Text(
                      "Login",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    );
                  }
                })),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            InkWell(
              onTap: () => Get.to(() => RegisterScreen()),
              child: Text(
                "Belum punya akun? Register",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
