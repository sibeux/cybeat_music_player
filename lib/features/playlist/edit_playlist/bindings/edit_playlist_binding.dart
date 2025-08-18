import 'package:cybeat_music_player/features/playlist/edit_playlist/controllers/edit_playlist_controller.dart';
import 'package:get/get.dart';

class EditPlaylistBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<EditPlaylistController>(() => EditPlaylistController());
  }
}