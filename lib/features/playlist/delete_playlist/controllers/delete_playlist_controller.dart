import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DeletePlaylistController extends GetxController {
  void deletePlaylist(String id) async {
    final homeAlbumGridController = Get.find<HomeController>();

    homeAlbumGridController.removePlaylist(id);
    String url = dotenv.env['CRUD_PLAYLIST_API_URL'] ?? '';

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
