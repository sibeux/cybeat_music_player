import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/controllers/add_music_to_playlist_controller.dart';
import 'package:get/get.dart';

class AddMusicToPlaylistBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<AddMusicToPlaylistController>(() => AddMusicToPlaylistController());
  }
}