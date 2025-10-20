import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_app_name/core/themes/app_colors.dart';
import 'package:your_app_name/modules/intro/controllers/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _controller = Get.put(SplashController());
  @override
  void initState() {
    super.initState();
    _controller.initAppFlow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.primaryColor,
            AppColors.secondPrimaryColor,
          ],
        )),
        child: Center(
          child: Image.asset(
            "assets/images/splashlogo.png",
            // height: ScreenInfo.screenHeight > 700 ? 75 : 60,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
