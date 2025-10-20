import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_app_name/core/routes/app_routes.dart';
import 'package:your_app_name/core/themes/app_colors.dart';

class IntroViewScreen extends StatelessWidget {
  const IntroViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: 0,
              bottom: 300,
              left: 0,
              right: 0,
              child: Image.asset(
                "assets/images/banner_background.png",
                fit: BoxFit.cover,
              )),
          Positioned.fill(
            top: 50,
            left: 0,
            right: 50,
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/images/banner_man.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 410,
            left: 0,
            right: 180,
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/images/Coint.png",
                // width: screenWidth * 0.9,
              ),
            ),
          ),
          Positioned(
            top: 440,
            left: 150,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/images/Donut.png",
                // width: screenWidth * 0.9,
              ),
            ),
          ),
          Positioned(
            top: 600,
            left: 0,
            bottom: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Spend Smarter",
                  style: GoogleFonts.inter(
                      fontSize: 40,
                      height: 1,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor),
                ),
                Text(
                  'Save More',
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 60,
                  width: 320,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondPrimaryColor.withAlpha(100),
                        offset: const Offset(4, 4),
                        blurRadius: 8,
                        spreadRadius: 5,
                      ),
                    ],
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 58, 168, 161),
                        AppColors.secondPrimaryColor
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.homeScreen);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                RichText(
                  text: TextSpan(
                    text: 'Already Have Account?',
                    style: GoogleFonts.inter(color: Colors.black),
                    children: const [
                      TextSpan(
                        text: ' Log In',
                        style: TextStyle(color: AppColors.secondPrimaryColor),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
