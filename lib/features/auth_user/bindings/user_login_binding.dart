import 'package:cybeat_music_player/features/auth_user/controllers/user_login_controller.dart';
import 'package:get/get.dart';

class UserLoginBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<UserLoginController>(() => UserLoginController());
  }
}