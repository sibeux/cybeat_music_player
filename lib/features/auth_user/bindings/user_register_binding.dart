import 'package:cybeat_music_player/features/auth_user/controllers/user_register_controller.dart';
import 'package:get/get.dart';

class UserRegisterBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<UserRegisterController>(() => UserRegisterController());
  }
}