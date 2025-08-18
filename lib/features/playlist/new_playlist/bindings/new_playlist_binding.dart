import 'package:cybeat_music_player/features/playlist/new_playlist/controllers/new_playlist_controller.dart';
import 'package:get/get.dart';

class NewPlaylistBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<NewPlaylistController>(() => NewPlaylistController());
  }
}