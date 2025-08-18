import 'package:cybeat_music_player/features/album_music/controllers/album_music_controller.dart';
import 'package:get/get.dart';

class AlbumMusicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AlbumMusicController());
  }
}
