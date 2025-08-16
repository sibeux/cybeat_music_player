import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:cybeat_music_player/features/home/controllers/home_sort_preferences_controller.dart';
import 'package:get/get.dart';

class RootPageController extends GetxController {
  @override
  void onInit() {
    initialization();
    super.onInit();
  }

  Future<void> initialization() async {
    final homeAlbumGridController = Get.find<HomeController>();
    final sortPreferencesController = Get.put(HomeSortPreferencesController());
    // Ambil data filter sort dari Shared Preferences
    await sortPreferencesController.getSortBy();
    // Ambil data album dari database
    await homeAlbumGridController.initializeAlbum();
  }
}
