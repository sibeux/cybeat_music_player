import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:cybeat_music_player/features/home/controllers/home_filter_album_controller.dart';
import 'package:cybeat_music_player/features/home/controllers/home_sort_preferences_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Di sinilah Anda "mendaftarkan" controller Anda.
    // Get.lazyPut() adalah yang paling umum digunakan.
    // Controller baru akan dibuat saat pertama kali dibutuhkan.
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<HomeFilterAlbumController>(() => HomeFilterAlbumController());
    Get.lazyPut<HomeSortPreferencesController>(
        () => HomeSortPreferencesController());
  }
}
