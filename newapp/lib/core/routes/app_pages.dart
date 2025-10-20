import 'package:get/get.dart';
import 'package:your_app_name/modules/addexpense/views/add_expense_view.dart';
import 'package:your_app_name/modules/home/views/home.dart';
import 'package:your_app_name/modules/intro/views/intro_view.dart';
import 'package:your_app_name/modules/intro/views/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    // GetPage(name: AppRoutes.appScaffold, page: () => const AppScaffold()),
    GetPage(name: AppRoutes.splashScreen, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.splashScreen, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.introScreen, page: () => const IntroViewScreen()),
    GetPage(name: AppRoutes.homeScreen, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.addScreen, page: () => const AddExpenseView()),
    // Add your pages here
  ];
}
