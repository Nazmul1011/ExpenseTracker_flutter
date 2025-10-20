import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:your_app_name/core/controllers/base_controller.dart';

// import '../../../core/routes/app_routes.dart';
// import '../../auth/services/auth_service.dart';
// import '../../user/controllers/user_type_controller.dart';

class SplashController extends GetxController with BaseController {
  // final AuthService authService = AuthService();
  final GetStorage storage = GetStorage();
  // final userTypeCtrl = Get.find<UserTypeController>();

  Future<void> simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  Future<void> initAppFlow() async {
    setLoading(true);
    await simulateDelay();

    final hasSeenIntro = storage.read('hasSeenIntro') ?? false;

    if (!hasSeenIntro) {
      storage.write('hasSeenIntro', true);
      Get.offAllNamed('/intro');
      setLoading(false);
      return;
    }

    //  userType
    // if (!userTypeCtrl.hasSelection) {
    //   Get.offAllNamed(AppRoutes.userType);
    //   setLoading(false);
    //   return;
    // }

    // No auth check for now
    Get.offAllNamed('/home');
    setLoading(false);
  }

  // authentication-related logic not needed yet
  // Future<void> checkAuthStatus() async {}
  // void logOutUser() {}
}
