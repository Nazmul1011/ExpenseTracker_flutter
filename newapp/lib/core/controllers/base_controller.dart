import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/widgets/snack_bar/app_snack_bar.dart';

mixin BaseController on GetxController {
  final RxBool isLoading = false.obs;
  final RxBool hasInternet = true.obs;

  void setLoading(bool value) => isLoading.value = value;

  void setInternetStatus(bool isOnline) => hasInternet.value = isOnline;

  void showError(String message) {
    showSnack(
      content: message,
      status: SnackBarStatus.error,
    );
  }

  bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }
}
