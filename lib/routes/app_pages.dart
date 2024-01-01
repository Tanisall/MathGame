// ignore_for_file: prefer_const_constructors, constant_identifier_names

import 'package:game_flutter/pages/login.dart';
import 'package:game_flutter/pages/register.dart';
import 'package:game_flutter/pages/startup.dart';
import 'package:get/get.dart';

// import '../modules/home/views/home/home_component.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(name: _Paths.LOGIN, page: () => LoginScreen()),
    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterScreen(),
    ),
    GetPage(
      name: _Paths.STARTUP,
      page: () => StartupPage(),
    ),
  ];
}
