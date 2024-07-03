import 'package:cybeat_music_player/controller/home_album_grid_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SortPreferencesController extends GetxController {
  final sort = ''.obs;
  final isTapSort = false.obs;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final homeAlbumGridController = Get.put(HomeAlbumGridController());

  @override
  void onInit() {
    super.onInit();
    getSortBy();
  }

  Future<void> saveSortBy(String value) async {
    final SharedPreferences prefs = await _prefs;
    isTapSort.value = !isTapSort.value;

    switch (value) {
      case 'Recents':
        sort.value = 'uid';
        prefs.setString('sort', 'uid');
        homeAlbumGridController.initializeAlbum('uid');
        break;
      case 'Alphabetical':
        sort.value = 'title';
        prefs.setString('sort', 'title');
        homeAlbumGridController.initializeAlbum('title');
        break;
    }
  }

  Future<void> getSortBy() async {
    final SharedPreferences prefs = await _prefs;
    final sort = prefs.getString('sort') ?? 'uid';
    this.sort.value = sort;
  }

  get sortValue => sort.value;
}
