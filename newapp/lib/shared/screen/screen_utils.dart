import 'package:flutter/material.dart';

class ScreenInfo {
  static late double screenHeight;
  static late double screenWidth;

  static void init(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    screenHeight = size.height;
    screenWidth = size.width;
  }
}
