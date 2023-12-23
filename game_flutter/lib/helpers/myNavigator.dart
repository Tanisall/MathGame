import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyNavigator {
  static pushReplacement(BuildContext context, Widget page) {
    return Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        // transitionDuration: const Duration(milliseconds: 1500),
        pageBuilder: (context, animation, secondaryAnimation) {
          return page;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            // position: offsetAnimation,
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  static push(BuildContext context, Widget page) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        // transitionDuration: const Duration(milliseconds: 1500),
        pageBuilder: (context, animation, secondaryAnimation) {
          return page;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            // position: offsetAnimation,
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}
