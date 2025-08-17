
import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Di sinilah Anda "mendaftarkan" controller Anda.
    // Get.lazyPut() adalah yang paling umum digunakan.
    // Controller baru akan dibuat saat pertama kali dibutuhkan.
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
