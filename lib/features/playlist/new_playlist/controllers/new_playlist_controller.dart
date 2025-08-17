import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NewPlaylistController extends GetxController{
  var namePlaylist = ''.obs;

  void onChange(String value) {
    namePlaylist.value = value;
  }
  
  void addNewPlaylist(String name) async {
    final homeController = Get.find<HomeController>();
    // homeController.isLoadingAddPlaylist.value = true;
    const String url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/crud_new_playlist';

    try {
      await http.post(
        Uri.parse(url),
        body: {
          'method': 'create',
          'name_playlist': name,
        },
      );

      showRemoveAlbumToast('Playlist added to your library');
    } catch (e) {
      logError('Error add new playlist: $e');
    } finally {
      // homeController.isLoadingAddPlaylist.value = false;
      homeController.initializeAlbum();
    }
  }
}