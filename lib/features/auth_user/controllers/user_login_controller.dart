import 'package:get/get.dart';

class UserLoginController extends GetxController {
  var isLoading = false.obs;
  var isLoginSuccess = true.obs;
  var isRedirecting = false.obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
    isLoginSuccess.value = true;
    isRedirecting.value = false;
  }
}
