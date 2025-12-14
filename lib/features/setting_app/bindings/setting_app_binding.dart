import 'package:cybeat_music_player/features/setting_app/controllers/setting_app_controller.dart';
import 'package:get/get.dart';

class SettingAppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingAppController());
  }
}
