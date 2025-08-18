import 'package:cybeat_music_player/features/search_album/controllers/search_album_controller.dart';
import 'package:get/get.dart';

class SearchAlbumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchAlbumController());
  }
}
