import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DeletePlaylistController extends GetxController {
  void deletePlaylist(String id) async {
    final homeAlbumGridController = Get.find<HomeController>();

    homeAlbumGridController.removePlaylist(id);
    const String url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/crud_new_playlist';

    try {
      await http.post(
        Uri.parse(url),
        body: {
          'method': 'delete',
          'playlist_uid': id,
        },
      );
    } catch (e) {
      logError('Error delete playlist: $e');
    }
  }
}
